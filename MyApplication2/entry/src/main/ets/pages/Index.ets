// import {router} from '@kit.ArkUI';
// import {BusinessError} from '@kit.BasicServicesKit';
import router from '@ohos.router';     //导入router模块
@Entry
@Component
struct Index {
  @State message: string = 'Hello World'
  pageInfos: NavPathStack = new NavPathStack()
  isUseInterception: boolean = false;
  @State translateY_Logo:number = -200    //定义一个用@state修饰的number型变量translateY_Logo
  @State translateY_Title:number = 200    //定义一个用@state修饰的number型变量translateY_Title

  build() {
    Navigation() {
      // Navigation(this.pageInfos) {
      Row() {
        Column() {

          //删除页面初始化时默认带有的Text组件, 增加一个新的image件和一个新的Text组件

          Image($r('app.media.huaweiIcon'))
            .height(120)
            .width(120)
            .translate({
              y: this.translateY_Logo
            })
            .animation({
              //播放时长（ms）
              duration: 2000,
              //播放速度
              tempo: 1,
              //播放曲线，所选择的是‘快出慢入’
              curve: Curve.FastOutSlowIn,
              //延迟（ms）
              delay: 500,
              //循环次数（-1为无限循环）
              iterations: 1,
              //播放模式
              playMode: PlayMode.Normal
            })

          Text('PCB工业质检')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({
              top: 7
            })//添加关键属性
            .translate({
              y: this.translateY_Title
            })
            .animation({
              delay: 500,
              duration: 2000,
              curve: Curve.FastOutSlowIn,
              tempo: 1,
            })//增加onAppear回调
            .onAppear(() => {
              //改变属性参数
              this.translateY_Logo = 0
              this.translateY_Title = 0

              //设置定时器
              let id = setInterval(() => {
                //打印日志
                console.info('router to Second')
                //页面跳转
                // this.pageInfos.pushPath({ name: 'Upload' })
                router.pushUrl({
                  url:'pages/Upload'
                })
                //定时器执行之后立即销毁
                clearInterval(id)
              }, 3000, [])
            })

        }
        .width('100%')
      }
      .height('100%')
    }
  }
}
// @Entry
// @Component
// struct Index {
//   @State message: string = 'Hello World';
//   @State Next: string='Next';
//
//   pageInfos: NavPathStack = new NavPathStack()
//   isUseInterception: boolean = false;
//
//   build() {
//     Navigation(this.pageInfos){
//       Row(){
//         Column(){
//           Text(this.message)
//             .id('HelloWorld')
//             .fontSize(50)
//             .fontWeight(FontWeight.Bold)
//             .alignRules({
//               center: { anchor: '__container__', align: VerticalAlign.Center },
//               middle: { anchor: '__container__', align: HorizontalAlign.Center }
//             })
//           Button(){
//             Text(this.Next)
//               .fontSize(30)
//               .fontWeight(FontWeight.Bold)
//           }
//           .stateEffect(true)
//           .type(ButtonType.Capsule)
//           .margin({
//             top: 20
//           })
//           .backgroundColor('#87CEFA')
//           .width('40%')
//           .height('%5')
//           .onClick(() => {
//             this.pageInfos.pushPath({name:'Upload'})
//           })
//         }
//         .width('100%')
//       }
//       .height('100%')
//     }
//
//   }
// }