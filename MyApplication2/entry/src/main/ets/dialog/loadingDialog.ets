import hilog from '@ohos.hilog'

@CustomDialog
export struct LoadingDialog {
  @Prop loadingTips: string
  @State rotateAngle: number = 0
  //弹窗控制器
  controller: CustomDialogController
  private tag: string = 'LoadingDialog'

  aboutToAppear() {
    // setTimeout(()=>{
    //   this.rotateAngle =360;
    // },500)
    // hilog.debug(0xFFFF, this.tag ,"Loading展示》》》》》")
  }

  build() {
    Stack() {
      Column() {
        Image($r('app.media.common_loading'))
          .height(50)
          .width(50)
          .rotate({angle: this.rotateAngle })
          .animation({
            // duration: 3000,
            tempo:1,
            delay:0,
            playMode:PlayMode.Normal,
            iterations: -1,
            curve: Curve.Friction
          }).onAppear(() => {
          this.rotateAngle = 360
        })
        Text(this.loadingTips)
          .fontSize('15fp')
          .margin({ top: 10 })
      }
      .justifyContent(FlexAlign.Center)
      .height(150)
      .width(150)
      .backgroundColor(Color.White)
      .border({ radius: 5 })
    }
  }
}