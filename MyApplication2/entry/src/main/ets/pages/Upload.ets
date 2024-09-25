import router from '@ohos.router';
import { MediaBean } from '../bean/MediaBean';
import { MediaHelper } from '../helper/MediaHelper';
import { BusinessError } from '@kit.BasicServicesKit';
import { Log } from '../utils/Log';
import http from '@ohos.net.http';
import { LoadingDialog } from  '../dialog/loadingDialog';
// import { fileIo as fs , ReadOptions } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import picker from '@ohos.file.picker';
import systemDateTime from '@ohos.systemDateTime';
import buffer from '@ohos.buffer';
import { request } from '@kit.BasicServicesKit';
import httpRequest from '../httpRequest/httpRequest';
import { JSON } from '@kit.ArkTS';
import { MyResult } from '../bean/DetectResult'
import { DetectionBoxes } from '../bean/DetectResult'
import image from '@ohos.multimedia.image'
import { drawing } from '@kit.ArkGraphics2D';

enum MediaOption {
  Picture = 0,
  File = 1,
  TakePhoto = 2
}

//second.ets

@Builder
export function UploadBuilder(name: string, param: Object) {
  Upload()
}

@Entry
@Component
export struct Upload {

  @State images: MediaBean[] =[
    {
      No: -1,
      detection_classes: [],
      detection_boxes: [],
      detection_scores: [],
      result: "",
      fileName: 'addPicture',
      localUrl: 'http://m.qpic.cn/psc?/V14SfwCO1KlIr7/TmEUgtj9EK6.7V8ajmQrENUPEtpdUSD*MBhDu0mS*8Jrd6mPsG83NTmDvewrJLYySOFvq1cQalLgSUjR4jWc4nTa.L8TW0PlWAsKees0cmo!/b&bo=yADIAAAAAAADByI!&rf=viewer_4'
    }
  ];
  @State message:string='待检测PCB'
  @State Back:string='Back'
  @State uploadUrl: string = "https://infer-modelarts-cn-southwest-2.myhuaweicloud.com/v1/infers/c14ed7e8-13c5-4391-80fa-eb35d8b5e9b8"
  @State res: string=""
  @State img: PixelMap = image.createPixelMapSync(new ArrayBuffer(5 * 5), {size: {height: 5, width: 5}})
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  @State isLoading: boolean = true;
  @State mediaBean: MediaBean = new MediaBean();
  private mediaHelper: MediaHelper = new MediaHelper(getContext());
  private customDialogController: CustomDialogController = new CustomDialogController({
    builder: Object
  });
  pageInfos: NavPathStack = new NavPathStack()
  isUseInterception: boolean = false;
  LoadingDialog: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      loadingTips: '检测中...'
    }),
    offset: { dx: 0, dy: -25 } ,
    customStyle:true,
    autoCancel:false
  })
  // loadingDialogDisappear() {
  //   this.LoadingDialog = null // 将dialogController置空
  // }

  build() {
    Navigation(this.pageInfos){
      Row() {
        Column() {
          Text(" ")
            .fontSize(70)
          // Image(this.img)
          //   .height(300)
          //   .width(300)
          //   .objectFit(ImageFit.Fill)
          //   .borderWidth(1)
          // Canvas(this.context)
          //   .width(300)
          //   .height(300)
          Text(this.message)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
          Grid() {
            ForEach(this.images, (image: MediaBean, index: number) => {
              GridItem() {
                Image(image.localUrl)
                  .height(110)
                  .width(110)
                  .objectFit(ImageFit.Fill)
                  // .backgroundImage($r('app.media.addPicture'))
                  // .backgroundImageSize(ImageSize.FILL)
                  .onClick(() => {
                    if(image.localUrl=='http://m.qpic.cn/psc?/V14SfwCO1KlIr7/TmEUgtj9EK6.7V8ajmQrENUPEtpdUSD*MBhDu0mS*8Jrd6mPsG83NTmDvewrJLYySOFvq1cQalLgSUjR4jWc4nTa.L8TW0PlWAsKees0cmo!/b&bo=yADIAAAAAAADByI!&rf=viewer_4') {
                      ActionSheet.show({
                        title: '多媒体选择',
                        message: ' ',
                        autoCancel: true,
                        confirm: {
                          value: '取消',
                          action: () => {
                            console.log('Get Alert Dialog handled')
                          }
                        },
                        cancel: () => {
                          console.log('actionSheet canceled')
                        },
                        alignment: DialogAlignment.Bottom,
                        offset: { dx: 0, dy: 0 },
                        sheets: [
                          {
                            title: '选择图片',
                            icon: $r('app.media.album'),
                            action: () => {
                              // this.handleClick(MediaOption.Picture)
                              this.handleClick(MediaOption.Picture, this.images)
                              console.log('点击选择图片')
                              Log.info(this.message, 'images长度：' + this.images.length)
                            }
                          },
                          {
                            title: '选择文件',
                            icon: $r('app.media.file'),
                            action: () => {
                              // this.handleClick(MediaOption.File)
                              this.handleClick(MediaOption.File, this.images)
                              console.log('点击选择文件')
                            }
                          }
                        ]
                      })
                      Log.info(this.message, '长度：' + this.images.length)
                    }
                    else {
                      // router.pushUrl({
                      //   url: "pages/SwiperPage",
                      //   params: {
                      //     images: this.images,
                      //     index: index
                      //   }
                      // })
                    }
                  })
              }
            },(image:MediaBean) => image.localUrl)
          }
            .columnsTemplate('1fr 1fr 1fr')//三等分
            .columnsGap(10) //列之间间距
            .rowsGap(10) //行之间间距
            .supportAnimation(true)
            .width('90%')
            .height(450)
            .margin({ top: 20 })
            .enableScrollInteraction(true)
            .multiSelectable(false)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.On)
            .scrollBarColor(Color.Grey)
            .scrollBarWidth(4)
            .backgroundColor(0xF0F0F0)
            .onScrollIndex((first: number, last: number) => {
              console.info(first.toString())
              console.info(last.toString())
            })
            // .onScrollBarUpdate((index: number, offset: number) => {
            //   console.info("XXX" + 'Grid onScrollBarUpdate,index : ' + index.toString() + ",offset" + offset.toString())
            //   return { totalOffset: (index / 5) * (80 + 10) - offset, totalLength: 80 * 5 + 10 * 4 }
            // })  //只适用于当前示例代码数据源，如果数据源有变化，则需要修改该部分代码，或者删掉此属性
            .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
              console.info(scrollOffset.toString())
              console.info(scrollState.toString())
            })
            .onScrollStart(() => {
              console.info("XXX" + "Grid onScrollStart")
            })
            .onScrollStop(() => {
              console.info("XXX" + "Grid onScrollStop")
            })
            // .onReachStart(() => {
            //   this.gridPosition = 0
            //   console.info("XXX" + "Grid onReachStart")
            // })
            // .onReachEnd(() => {
            //   this.gridPosition = 2
            //   console.info("XXX" + "Grid onReachEnd")
            // })

          Button(){
            Text('检测')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ffffffff')
          }
          .stateEffect(true)
          .type(ButtonType.Capsule)
          .margin({
            top: 20
          })
          .backgroundColor('#ffba081d')
          .width('40%')
          .height('7%')
          .onClick(async  () => {
            //todo: 连接modelArts，跳转到Detect界面显示，之间如何异步监听，获得结果再跳转
            this.LoadingDialog.open()
            this.uploadFile()
            // setTimeout(() => {
            //   this.LoadingDialog.close()
            //   this.pageInfos.pushPath({name:'Detect'})
            // }, 5000);
            // let token:string=''
            // let result:boolean=false
            // let tokenRes=http.createHttp()
            // let data=await tokenRes.request(
            //   'https://iam.cn-southwest-2.myhuaweicloud.com/v3/auth/tokens',
            //   {
            //     method: http.RequestMethod.POST,
            //     header: {
            //       'Content-Type': 'application/json'
            //     },
            //     extraData:{
            //       "auth": {
            //         "identity": {
            //           "methods": [
            //             "password"
            //           ],
            //           "password": {
            //             "user": {
            //               "domain": {
            //                 "name": "mchehega"        //IAM用户所属账号名
            //               },
            //               "name": "a123456",             //IAM用户名
            //               "password": "123456789a"      //IAM用户密码
            //             }
            //           }
            //         },
            //         "scope": {}
            //       }
            //     }
            //   }
            // )
            //
            // if(data.responseCode>=200 && data.responseCode<300)
            // {
            //   // this.message = data.header['x-subject-token']
            //   let httpRes = http.createHttp()
            //   let response = httpRes.request(
            //     "https://infer-modelarts-cn-southwest-2.myhuaweicloud.com/v1/infers/c14ed7e8-13c5-4391-80fa-eb35d8b5e9b8",
            //     {
            //       method: http.RequestMethod.POST,
            //       header: {
            //         'Content-Type': 'application/json',
            //         'x-subject-token': data.header['x-subject-token']
            //       },
            //       extraData:{
            //         data: fs.read(file.fd, buf)
            //       },
            //       expectDataType: http.HttpDataType.ARRAY_BUFFER
            //     }
            //   )
            //
            //   await response.then((data) => {
            //     const code = data.responseCode
            //     if (code == 200) {
            //       const response = data.result + "";
            //       this.message = response
            //     }else if (code === 401){
            //       console.log(this.message,'failed')
            //       // 登录状态失效
            //     }
            //   })
            // }
            //
            //
            // else{
            //   console.log("failed")
            // }
            // tokenRes.destroy()
            // return token

          })
        }
        .width('100%')
      }
      .height('100%')
    }
    // .onBackPressed(() => {
    //   const popDestinationInfo = this.pageInfos.pop()
    //   console.log('pop'+'返回值'+JSON.stringify(popDestinationInfo))
    //   return true
    // }).onReady((context: NavDestinationContext) => {
    //   this.pageInfos = context.pathStack
    // })

  }

  //构造上传文件的body内容
  buildBodyContent(boundary: string, fileName: string, content: Uint8Array, contentType: string = "application/octet-stream") {
    let textEncoder = new util.TextEncoder();

    //构造文件内容前的部分
    let preFileContent = `--${boundary}\r\n`
    preFileContent = preFileContent + `Content-Disposition: form-data; name="file"; filename="${fileName}"\r\n`
    preFileContent = preFileContent + `Content-Type: ${contentType}\r\n`
    preFileContent = preFileContent + '\r\n'
    let preArray = textEncoder.encodeInto(preFileContent)

    //构造文件内容后的部分
    let aftFileContent = '\r\n'
    aftFileContent = aftFileContent + `--${boundary}`
    aftFileContent = aftFileContent + '--\r\n'
    let aftArray = textEncoder.encodeInto(aftFileContent)

    //文件前后内容和文件内容组合
    let bodyBuf = buffer.concat([preArray, content, aftArray])
    return bodyBuf.buffer
  }

  async copy2Sandbox(srcUri: string, fileName: string): Promise<string> {
    let context = getContext(this)
    //计划复制到的目标路径
    let realUri = context.cacheDir + "/" + fileName

    //复制选择的文件到沙箱cache文件夹
    try {
      let file = await fs.open(srcUri);
      fs.copyFileSync(file.fd, realUri)
      fs.close(file)
    } catch (err) {
      Log.error(this.message, 'err.code : ' + err.code + ', err.message : ' + err.message);
    }

    return realUri
  }

  //上传文件
  // uploadFile() {
  async uploadFile() {
  //   //将图片转换成pixelMap
  //   //打开文件
  //   // let file = fs.openSync(this.images[i].localUrl,fs.OpenMode.READ_ONLY)
  //   let file = fs.openSync("file://docs/storage/Users/currentUser/Download/com.huawei.hmos.browser/01_spurious_copper_14.jpg",fs.OpenMode.READ_ONLY)
  //   //读取文件大小
  //   let info = fs.statSync(file.fd);
  //   //缓存照片数据
  //   let bufferImg: ArrayBuffer = new ArrayBuffer(info.size);
  //   //写入缓存
  //   fs.readSync(file.fd, bufferImg);
  //   //关闭文件流
  //   fs.closeSync(file);
  //   //创建imageResource
  //   let imageResource = image.createImageSource(bufferImg);
  //   //创建pixelMap
  //   this.img =  imageResource.createPixelMapSync();
  //
  //   // TODO:知识点:通过OffscreenCanvasRenderingContext2D绘制水印
  //   let imageInfo =  this.img.getImageInfoSync()
  //
  //   // this.images[i].detection_image = await imageResource.createPixelMap();
  //   let width = imageInfo.size.width
  //   let height = imageInfo.size.height
  //   let imgg:ImageBitmap = new ImageBitmap("file://docs/storage/Users/currentUser/Download/com.huawei.hmos.browser/01_spurious_copper_14.jpg")
  //   let offCanvas: OffscreenCanvas = new OffscreenCanvas(width,height)
  //   // let offC2d = offCanvas.getContext("2d",this.settings)
  //   let offC2d = new OffscreenCanvasRenderingContext2D(width,height,{ antialias: true })
  //   Log.info(this.message,"height: "+height+",width: "+width)
  //   // 配置 OffscreenCanvasRenderingContext2D
  //   offC2d.font = 'normal bolder 60px sans-serif'
  //   offC2d.fillStyle = 'rgb(255,0,0)'
  //   offC2d.textAlign = 'center'
  //   offC2d.textBaseline = 'middle'
  //   // 绘制图像
  //   offC2d.drawImage(this.img, 0, 0, width, height, 0, 0, width/3, height/3)
  //   // 绘制文字
  //   offC2d.globalCompositeOperation = 'source-over'
  //   offC2d.fillText("sdfghkjbvghchjkilkjnh", width/6, height/6)
  //   this.img = offC2d.getPixelMap(0,0,width/3,height/3)
  //   // offC2d.setPixelMap(this.img)
  //   // this.context.transferFromImageBitmap(offCanvas.transferToImageBitmap())

    let token:string=''
    let result:boolean=false
    let tokenRes=http.createHttp()
    let data=await tokenRes.request(
      'https://iam.cn-southwest-2.myhuaweicloud.com/v3/auth/tokens',
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData:{
          "auth": {
            "identity": {
              "methods": [
                "password"
              ],
              "password": {
                "user": {
                  "domain": {
                    "name": "mchehega"        //IAM用户所属账号名
                  },
                  "name": "a123456",             //IAM用户名
                  "password": "123456789a"      //IAM用户密码
                }
              }
            },
            "scope": {
              "project": {
                "id": "7b776ce51501460095f005a8f2bb39ce",
                "name": "cn-southwest-2"
              }
            }
          }
        }
      }
    )
    Log.info(this.message, "token生成成功")

    if(data.responseCode>=200 && data.responseCode<300)
    {
      let images_copy: MediaBean[] = []
      for(let i=0; i<=this.images.length - 2; i++)
      {
        // this.images[i].No=i
        let myResult: MyResult
        let uploadFilePath = this.images[i].localUrl
        let uploadFileName = this.images[i].fileName
        //上传文件使用的分隔符
        let boundary: string =
          '----ShandongCaoxianNB666MyBabyBoundary' + (await systemDateTime.getCurrentTime(true)).toString()

        let sandFile = await this.copy2Sandbox(uploadFilePath, uploadFileName)

        //选择要上传的文件的内容
        let fileContent: Uint8Array = new Uint8Array(this.readContentFromFile(sandFile))

        //上传请求的body内容
        let bodyContent = this.buildBodyContent(boundary, uploadFileName, fileContent)


        //http请求对象
        let httpRequest = http.createHttp();
        let opt: http.HttpRequestOptions = {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': `multipart/form-data; boundary=${boundary}`,
            'Content-Length': bodyContent.byteLength.toString(),
            'x-auth-token': data.header['x-subject-token']
          },
          extraData: bodyContent,
          // expectDataType: http.HttpDataType.ARRAY_BUFFER
        }

        //发送上传请求
        httpRequest.request(this.uploadUrl, opt)
          .then(async (resp) => {
            Log.info(this.message, "获取响应")
            //将图片转换成pixelMap
            //打开文件
            let file = fs.openSync(this.images[i].localUrl,fs.OpenMode.READ_ONLY)
            //读取文件大小
            let info = fs.statSync(file.fd);
            //缓存照片数据
            let bufferImg: ArrayBuffer = new ArrayBuffer(info.size);
            //写入缓存
            fs.readSync(file.fd, bufferImg);
            //关闭文件流
            fs.closeSync(file);
            //创建imageResource
            let imageResource = image.createImageSource(bufferImg);
            //创建pixelMap
            // this.images[i].detection_image =  imageResource.createPixelMapSync();
            this.images[i].detection_image = imageResource.createPixelMapSync();

            Log.info(this.message, "响应码：" + resp.responseCode +"上传成功 " + "响应结果：" + resp.result)
            const responseStr = resp.result+""
            myResult = JSON.parse(responseStr) as Object
            this.images[i].detection_classes = myResult.detection_classes as string[]
            this.images[i].detection_boxes = myResult.detection_boxes as number[][]
            this.images[i].detection_scores = myResult.detection_scores as number[]
            this.images[i].detection_image =  this.drawTextToImage(this.images[i].detection_image as image.PixelMap,this.images[i].detection_classes,this.images[i].detection_boxes,this.images[i].detection_scores)
            // const imageInfo =  picture.getImageInfoSync()
            // const width = imageInfo.size.width
            // const height = imageInfo.size.height
            // Log.info(this.message,"height: "+height+",width: "+width)
            // let settings: RenderingContextSettings = new RenderingContextSettings(true)
            // let offC2d = new OffscreenCanvasRenderingContext2D(width, height, settings)
            // offC2d.drawImage(picture,0,0,width,height)
            // this.images[i].detection_image = offC2d.getPixelMap(0,0,width,height)

            this.images[i].result += "响应码：" + resp.responseCode + "\r\n"
            this.images[i].result += "上传成功\r\n"
            this.images[i].result += "响应结果：" + resp.result + "\r\n"
            images_copy.push(this.images[i])
            // router.pushUrl({
            //   url: 'pages/Detect' // 目标url
            // }, router.RouterMode.Standard, (err) => {
            //   if (err) {
            //     console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
            //     return;
            //   }
            //   console.info('Invoke pushUrl succeeded.');
            // });
          })
          .catch(() => {
            this.images[i].result += "请求失败"
            Log.error(this.message, "请求失败")
          })
      }
      setTimeout(() => {
        this.LoadingDialog.close()
        // const routerParams: object = this.images
        const routerParams: object = images_copy
        if(this.images[0].detection_image !=undefined){
          Log.info(this.message,"OK")}
        Log.info(this.message,"跳转页面")
        this.pageInfos.pushPathByName("Detect", routerParams)
      },50000)
    }
    else{
      Log.error(this.message, "token生成失败")
    }
    tokenRes.destroy()
    return token
  }

  drawTextToImage(img: image.PixelMap, detection_classes: string[],detection_boxes:number[][], detection_scores:number[]): PixelMap
  {
    const imageInfo =   img.getImageInfoSync()
    const width = imageInfo.size.width
    const height = imageInfo.size.height
    const offC2d = new OffscreenCanvasRenderingContext2D(width, height, {
      antialias: true
    })
    Log.info(this.message,"height: "+height+",width: "+width)
    Log.info(this.message,"detection_classes: "+detection_classes)
    // 配置 OffscreenCanvasRenderingContext2D
    // 绘制图像
    offC2d.drawImage(img, 0, 0, width, height, 0, 0, width/3, height/3)
    for(let i=0;i<=detection_classes.length-1;i++)
    {
      //绘制矩形框
      // offC2d.globalCompositeOperation = 'xor'
      offC2d.lineWidth = 1
      offC2d.strokeStyle= 'rgba(0, 255, 0, 1.00)'
      // offC2d.strokeRect(width/6,height/6,detection_boxes[i][2]/3-detection_boxes[i][0]/3,detection_boxes[i][3]/3-detection_boxes[i][1]/3)
      offC2d.strokeRect(detection_boxes[i][1]/3,detection_boxes[i][0]/3,detection_boxes[i][3]/3-detection_boxes[i][1]/3,detection_boxes[i][2]/3-detection_boxes[i][0]/3)
      Log.info(this.message,"x1:"+detection_boxes[i][0]+";y1:"+detection_boxes[i][1]+";x2:"+detection_boxes[i][2]+";y2:"+detection_boxes[i][3])
      // 绘制文字
      offC2d.font = 'normal bolder 60px sans-serif'
      offC2d.fillStyle = 'rgba(255, 255, 255, 1.00)'
      offC2d.textBaseline = 'bottom'
      // if(detection_boxes[i][1]/3>width/6){
      //   offC2d.textAlign = 'end'
      //   offC2d.fillText(detection_classes[i]+"("+Math.floor(detection_scores[i] * 10000) / 100.0+"%)", detection_boxes[i][3]/3, detection_boxes[i][0]/3)
      // }
      // else {
      //   offC2d.textAlign = 'start'
      //   offC2d.fillText(detection_classes[i]+"("+Math.floor(detection_scores[i] * 10000) / 100.0+"%)", detection_boxes[i][1]/3, detection_boxes[i][0]/3)
      // }
      offC2d.textAlign = 'center'
      offC2d.fillText(detection_classes[i]+"("+Math.floor(detection_scores[i] * 10000) / 100.0+"%)", detection_boxes[i][1]/3, detection_boxes[i][0]/3)
      Log.info(this.message,"string:"+detection_classes[i]+";x:"+detection_boxes[i][0]+";y:"+detection_boxes[i][1])
    }
    return offC2d.getPixelMap(0, 0, width/3, height/3)
  }


  async handleClick(option: MediaOption,images: Array<MediaBean>) {
      let mediaBeans: Array<MediaBean>;
      let mediaBean: MediaBean;
      switch (option) {
        case MediaOption.Picture:
          Log.info(this.message, '时刻1')
          mediaBeans = await this.mediaHelper.selectPicture(images);
          Log.info(this.message, '时刻2')
          Log.info(this.message, 'mediaBeans长度：')
          Log.info(this.message, '选择图片：'+mediaBeans)
          break;
        case MediaOption.File:
          Log.info(this.message, '时刻1')
          mediaBeans = await this.mediaHelper.selectFile(images);
          Log.info(this.message, '时刻2')
          Log.info(this.message, 'mediaBeans长度：')
          Log.info(this.message, '选择图片：'+mediaBeans)
          break;
      // case MediaOption.TakePhoto:
      //   mediaBean = await this.mediaHelper.takePhoto(getContext() as common.UIAbilityContext);
      //   break;
        default:
          mediaBeans = await this.mediaHelper.selectPicture(images);
          break;
      }
      Log.info(this.message, '选择图片：'+mediaBeans)
      Log.info(this.message, 'mediaBeans长度：'+mediaBeans.length)

      if (mediaBeans) {
        for(let i=0;i<=mediaBeans.length-1;i++)
        {
          Log.info(this.message, '选择图片的URL'+i+":"+mediaBeans[i].localUrl)
          mediaBeans[i].No = i
        }
        this.images = mediaBeans;

      }
  }


  //从文件读取内容
  readContentFromFile(fileUri: string): ArrayBuffer {
    let file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
    let fsStat = fs.lstatSync(fileUri);
    let buf = new ArrayBuffer(fsStat.size);
    fs.readSync(file.fd, buf);
    fs.fsyncSync(file.fd)
    fs.closeSync(file);
    return buf
  }

  // pageInfos: NavPathStack = new NavPathStack()
}