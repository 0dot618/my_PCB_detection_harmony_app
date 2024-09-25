import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import picker from '@ohos.file.picker';
import { MediaBean } from '../bean/MediaBean';
import { MediaSelectBean } from '../bean/MediaSelectBean';
import { MediaHelper } from '../helper/MediaHelper';
import { BusinessError } from '@kit.BasicServicesKit';
import { Log } from '../utils/Log';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { image } from '@kit.ImageKit';
import fileIo from '@ohos.file.fs';
import { componentSnapshot } from '@kit.ArkUI';
import { abilityAccessCtrl,Permissions } from '@kit.AbilityKit';
// import { abilityAccessCtrl,common,Permissions } from '@kit.AbilityKit';
import { intl } from '@kit.LocalizationKit';
// import { fileIo } from '@kit.CoreFileKit';
const permissions: Array<Permissions> = ['ohos.permission.WRITE_IMAGEVIDEO'];
function reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
  let atManager: abilityAccessCtrl.AtManager =
    abilityAccessCtrl.createAtManager();
  // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        // 用户授权，可以继续访问目标操作
      } else {
        // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
        return;
      }
    }
    // 授权成功
  }).catch((err: BusinessError) => {
    console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}

// @Entry
@Builder
export function DetectBuilder(name: string, param: Object) {
  Detect()
}
@Component
export struct Detect {

  pageInfos: NavPathStack = new NavPathStack()

  @State images: MediaBean[] = [];

  // @State images: ResourceStr[] =[$r('app.media.12_short_07_det'),$r('app.media.08_spur_07_det'),$r('app.media.04_mouse_bite_07_det')];
  //todo：images存检测结果，呈现届时下发的PCB板工业品图像及图像中的瑕疵位置和类型（瑕疵位置通过矩形检测框进行标记，瑕疵种类统一为英文标注，并给出各个矩形框的置信度）
  @State message:string='Detect'

  @State mediaBean: MediaBean = new MediaBean();

  // private settings: RenderingContextSettings = new RenderingContextSettings(true)
  // private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  controller: VideoController = new VideoController();
  @State context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  compare_students(a: MediaBean, b: MediaBean){
    return a.No - b.No;
  }

  aboutToAppear(): void {
    this.images.sort(this.compare_students)
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          Text('完成检测')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
          // Canvas(this.context)
          //   .height(300)
          //   .width(300)
          //   .renderFit(RenderFit.RESIZE_FILL)
          //   .onReady(() => {
          //     this.context.setPixelMap(this.images[0].detection_image)
          //   })
          // Image(this.images[0].detection_image)
          //   .height(300)
          //   .width(300)
          //   .objectFit(ImageFit.Fill)
          Grid() {
            ForEach(this.images, (image: MediaBean, index: number) => {
              GridItem() {
                // Canvas(this.context)
                Image(image.detection_image)
                // Text(image.result)
                // ForEach(this.images, (image: ResourceStr, index: number) => {
                //   GridItem() {
                //     Image(image)
                  .height(110)
                  .width(110)
                  .objectFit(ImageFit.Fill)
                  .onClick(() => {
                    router.pushUrl({
                      url: "pages/SwiperPage",
                      params: {
                        images: this.images,
                        index: index
                      }
                    })
                  })
                  // .onReady(() => {
                  //   // let img:ImageBitmap = new ImageBitmap(image.localUrl)
                  //   // this.context.imageSmoothingEnabled = false
                  //   // this.context.drawImage( img,0,0,110,110)
                  //   for(let i=0; i<=image.detection_classes.length-1;i++)
                  //   {
                  //     this.context.strokeRect(image.detection_boxes[i].x1,image.detection_boxes[i].y1,image.detection_boxes[i].x2,image.detection_boxes[i].y2)
                  //     this.context.font = '10px sans-serif'
                  //     this.context.fillText(image.detection_classes[i],image.detection_boxes[i].x1,image.detection_boxes[i].y1)
                  //   }
                  // })
              }
            }/*,(image:MediaBean) => image.localUrl*/)
          }
          .columnsTemplate('1fr 1fr 1fr')//三等分
          .columnsGap(10) //列之间间距
          .rowsGap(10) //行之间间距
          .supportAnimation(true)
          .width('90%')
          .height(450)
          .margin({ top: -45 })
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


          Button(){
            Text('保存结果')
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
          .width('50%')
          .height('7%')
          .onClick( () => {
            //todo：保存结果到相册或文件
            reqPermissionsFromUser(permissions, this.context);
            for(let i=0;i<=this.images.length-1;i++)
            {
              this.savePixmap2SysHelper(this.images[i].detection_image as image.PixelMap)
            }
          })

        }
        .width('100%')
      }
      .height('100%')
    }
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop()
      console.log('pop'+'返回值'+JSON.stringify(popDestinationInfo))
      return true
    }).onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
      this.images = context.pathStack.getParamByName("Detect")[0] as MediaBean[]
    })
  }


  // 保存到系统相册
  async savePixmap2SysHelper(pixmap:image.PixelMap) {
    if (!pixmap) {
      return;
    }
    const imgBuffer = await this.transferPixelMap2Buffer(pixmap);
    // 获取相册管理模块的实例，用于访问和修改相册中的媒体文件。
    let helper = photoAccessHelper.getPhotoAccessHelper(getContext(this));
    // 指定待创建的文件类型和后缀，创建图片或视频资源，使用callback方式返回结果。
    const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
    const file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    await fileIo.write(file.fd, imgBuffer);
    await fileIo.close(file.fd);
  }

  // 将pixelMap转成图片格式
  transferPixelMap2Buffer(pixelMap: image.PixelMap): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      /**
       * 设置打包参数
       * format：图片打包格式，只支持 jpg 和 webp
       * quality：JPEG 编码输出图片质量
       * bufferSize：图片大小，默认 10M
       */
      let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      // 创建ImagePacker实例
      const imagePackerApi = image.createImagePacker();
      imagePackerApi.packing(pixelMap, packOpts).then((buffer: ArrayBuffer) => {
        resolve(buffer);
      }).catch((err: BusinessError) => {
        reject();
      })
    })
  }
}