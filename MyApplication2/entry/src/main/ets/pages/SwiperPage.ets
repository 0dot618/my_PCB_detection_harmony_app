import router from '@ohos.router';
import { MediaBean } from '../bean/MediaBean';
import { Log } from '../utils/Log';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image'
import { display } from '@kit.ArkUI';

@Entry
@Component
struct SwiperPage {
  // @State images: ResourceStr[] = []
  // @State index: number = 0
  //
  // aboutToAppear() {
  //   let params: object = router.getParams()
  //   this.images = params["images"]
  //   this.index = params["index"]
  // }
  //
  // build() {
  //   Column() {
  //     Swiper() {
  //       ForEach(this.images, (item: ResourceStr) => {
  //         Image(item)
  //           .width("100%")
  //           .objectFit(ImageFit.Auto)
  //       })
  //     }
  //     .height("100%")
  //     .index(this.index)
  //     .indicatorStyle({
  //       color: '#ffffff'
  //     })
  //   }
  //   .width('100%')
  //   .height('100%')
  //   .backgroundColor(Color.Black)
  //   .justifyContent(FlexAlign.Center)
  //   .onClick(() => {
  //     // 点击返回至上一页面
  //     router.back()
  //   })
  // }
  @State images: MediaBean[] = []
  @State index: number = 0
  @State message: string = '阅览'
  @State imgs: image.PixelMap[] = []

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private offContext: OffscreenCanvasRenderingContext2D = new OffscreenCanvasRenderingContext2D(600, 600, this.settings)

  aboutToAppear() {
    let params: object = router.getParams()
    this.images = params["images"]
    this.index = params["index"]
    if(this.images[0].detection_image == undefined){
      Log.info(this.message, "NO")
    }
    Log.info(this.message, this.index.toString())
    for(let i=0;i<=this.images.length-1;i++)
    {
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
      let picture = imageResource.createPixelMapSync();
      Log.info(this.message,i+"生成前：")
      picture =  this.drawTextToImage(picture,this.images[i].detection_classes,this.images[i].detection_boxes,this.images[i].detection_scores)
      this.imgs.push(picture)
      Log.info(this.message,i+"生成后：")
    }
    Log.info(this.message, this.imgs.length.toString())

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

  build() {
    Column() {
      Swiper() {
        // ForEach(this.images, (item: MediaBean) => {
        //   Image(item.localUrl)
          ForEach(this.imgs, (item: image.PixelMap) => {
            Image(item)
            .width("100%")
            .objectFit(ImageFit.Auto)
        })
      }
      .height("100%")
      .index(this.index)
      .indicatorStyle({
        color: '#ffffff'
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击返回至上一页面
      router.back()
    })
  }

}

