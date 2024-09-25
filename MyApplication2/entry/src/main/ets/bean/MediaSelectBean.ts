export class MediaSelectBean {
  imageUrl: string//图片地址
  isAdd: boolean//是否是添加按钮

  constructor(imageUrl: string, isAdd: boolean) {
    this.imageUrl = imageUrl
    this.isAdd = isAdd
  }
}