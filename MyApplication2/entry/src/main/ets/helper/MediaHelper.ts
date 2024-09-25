import common from '@ohos.app.ability.common';
import picker from '@ohos.file.picker';
import mediaLibrary from '@ohos.multimedia.mediaLibrary';
import wantConstant from '@ohos.ability.wantConstant';
import { MediaBean } from '../bean/MediaBean';
import { StringUtils } from '../utils/StringUtils';
import { Log } from '../utils/Log';
import { BusinessError } from '@kit.BasicServicesKit';
import http from '@ohos.net.http';
// import { fileIo as fs , ReadOptions } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import systemDateTime from '@ohos.systemDateTime';
import buffer from '@ohos.buffer';
import { request } from '@kit.BasicServicesKit';
import httpRequest from '../httpRequest/httpRequest';

/**
 * 多媒体辅助类
 */
export class MediaHelper {
  private readonly TAG: string = 'MediaHelper';

  private mContext: common.Context;

  imgDatas: Array<string>

  constructor(context: common.Context) {
    this.mContext = context;
  }

  // //构造上传文件的body内容
  // buildBodyContent(boundary: string, fileName: string, content: Uint8Array, contentType: string = "application/octet-stream") {
  //   let textEncoder = new util.TextEncoder();
  //
  //   //构造文件内容前的部分
  //   let preFileContent = `--${boundary}\r\n`
  //   preFileContent = preFileContent + `Content-Disposition: form-data; name="file"; filename="${fileName}"\r\n`
  //   preFileContent = preFileContent + `Content-Type: ${contentType}\r\n`
  //   preFileContent = preFileContent + '\r\n'
  //   let preArray = textEncoder.encodeInto(preFileContent)
  //
  //   //构造文件内容后的部分
  //   let aftFileContent = '\r\n'
  //   aftFileContent = aftFileContent + `--${boundary}`
  //   aftFileContent = aftFileContent + '--\r\n'
  //   let aftArray = textEncoder.encodeInto(aftFileContent)
  //
  //   //文件前后内容和文件内容组合
  //   let bodyBuf = buffer.concat([preArray, content, aftArray])
  //   return bodyBuf.buffer
  // }

  // async copy2Sandbox(srcUri: string, fileName: string): Promise<string> {
  //   let context = getContext(this)
  //   //计划复制到的目标路径
  //   let realUri = context.cacheDir + "/" + fileName
  //
  //   //复制选择的文件到沙箱cache文件夹
  //   try {
  //     let file = await fs.open(srcUri);
  //     fs.copyFileSync(file.fd, realUri)
  //     fs.close(file)
  //   } catch (err) {
  //     Log.error('MediaHelper', 'err.code : ' + err.code + ', err.message : ' + err.message);
  //   }
  //
  //   return realUri
  // }

  /**
   * 选择图片
   */
  public selectPicture(images: Array<MediaBean>): Promise<Array<MediaBean>> {

    try {
      let selectNumber = 90 - images.length + 1;
      let photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = selectNumber < 0 ? 0 : selectNumber;
      let photoPicker = new picker.PhotoViewPicker();
      return photoPicker.select(photoSelectOptions)
        .then((photoSelectResult) => {

          Log.info(this.TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(photoSelectResult.photoUris));
          if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
            this.imgDatas = photoSelectResult.photoUris;
            for(let i=this.imgDatas.length - 1; i >= 0; i--) {
              Log.info(this.TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + this.imgDatas[i]);
            }
            return this.imgDatas;
          }

        }).catch((err) => {
          Log.error(this.TAG, 'PhotoViewPicker.select failed with err: ' + err);
          return err;
      }).then(async (imgDatas) => {
      // }).then((imgDatas) => {
          Log.info(this.TAG, 'images长度：'+images.length)
          for(let i=imgDatas.length - 1; i >= 0; i--) {
            const mediaBean: MediaBean = new MediaBean();
            mediaBean.localUrl = imgDatas[i];
            let segments = mediaBean.localUrl.split('/')
            //文件名称
            mediaBean.fileName = segments[segments.length-1]
            // const mediaBean = await this.buildMediaBean(uri);
            //上传文件使用的分隔符
            // mediaBean.boundary = '----ShandongCaoxianNB666MyBabyBoundary' + (await systemDateTime.getCurrentTime(true)).toString()

            // mediaBean.bodyContent = new ArrayBuffer(0)
            images.unshift(mediaBean);
            Log.info(this.TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + imgDatas[i]);
          }
          Log.info(this.TAG, 'images长度：'+images.length)
          return images;
        });
    } catch (err) {
      Log.error(this.TAG, 'PhotoViewPicker failed with err: ' + err);
      return Promise.reject(err);
    }
  }
  // public selectPicture(): Promise<MediaBean> {
  //
  //   try {
  //     let photoSelectOptions = new picker.PhotoSelectOptions();
  //     photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
  //     photoSelectOptions.maxSelectNumber = 1;
  //     let photoPicker = new picker.PhotoViewPicker();
  //     return photoPicker.select(photoSelectOptions)
  //       .then((photoSelectResult) => {
  //         Log.info(this.TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(photoSelectResult));
  //
  //         if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
  //           let filePath = photoSelectResult.photoUris[0];
  //           Log.info(this.TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + filePath);
  //           return filePath;
  //         }
  //
  //       }).catch((err) => {
  //         Log.error(this.TAG, 'PhotoViewPicker.select failed with err: ' + err);
  //         return err;
  //       }).then(async (filePath) => {
  //         const mediaBean = await this.buildMediaBean(filePath);
  //         return mediaBean;
  //       });
  //   } catch (err) {
  //     Log.error(this.TAG, 'PhotoViewPicker failed with err: ' + err);
  //     return Promise.reject(err);
  //   }
  // }

  /**
   * 选择文件
   */
  public selectFile(images: Array<MediaBean>): Promise<Array<MediaBean>> {
    try {
      let documentSelectOptions = new picker.DocumentSelectOptions();
      let documentPicker = new picker.DocumentViewPicker();
      return documentPicker.select(documentSelectOptions)
        .then((documentSelectResult) => {
          Log.info(this.TAG, 'DocumentViewPicker.select successfully, DocumentSelectResult uri: ' + JSON.stringify(documentSelectResult));

          if (documentSelectResult && documentSelectResult.length > 0) {
            for(let i=documentSelectResult.length - 1; i >= 0; i--) {
              Log.info(this.TAG,
                'DocumentViewPicker.select successfully, DocumentSelectResult uri: ' + documentSelectResult[i]);
            }
            return documentSelectResult;
          }

        }).catch((err) => {
          Log.error(this.TAG, 'PhotoViewPicker.select failed with err: ' + err);
          return err;
        }).then(async (imgDatas) => {
        // }).then(async (filePath) => {
        //   Log.info(this.TAG, 'images长度：'+images.length)
          for(let i=imgDatas.length - 1; i >= 0; i--) {
            const mediaBean: MediaBean = new MediaBean();
            mediaBean.localUrl = imgDatas[i];
            let segments = mediaBean.localUrl.split('/')
            //文件名称
            mediaBean.fileName = segments[segments.length-1]
            // const mediaBean = await this.buildMediaBean(uri);

            //上传文件使用的分隔符
            // mediaBean.boundary = '----ShandongCaoxianNB666MyBabyBoundary' + (await systemDateTime.getCurrentTime(true)).toString()
            //
            // //沙盒文件
            // let sandFile = await this.copy2Sandbox(mediaBean.localUrl, mediaBean.fileName)
            //
            // //选择要上传的文件的内容
            // let fileContent: Uint8Array = new Uint8Array(this.readContentFromFile(sandFile))
            //
            // //上传请求的body内容
            // mediaBean.bodyContent = this.buildBodyContent(mediaBean.boundary, mediaBean.fileName, fileContent)
            // mediaBean.bodyContent = new ArrayBuffer(0)

            images.unshift(mediaBean);
            Log.info(this.TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + imgDatas[i]);
          }
          Log.info(this.TAG, 'images长度：'+images.length)
          return images;

        });
    } catch (err) {
      Log.error(this.TAG, 'PhotoViewPicker failed with err: ' + err);
      return Promise.reject(err);
    }
  }

  // public selectFile(): Promise<MediaBean> {
  //   try {
  //     let documentSelectOptions = new picker.DocumentSelectOptions();
  //     let documentPicker = new picker.DocumentViewPicker();
  //     return documentPicker.select(documentSelectOptions)
  //       .then((documentSelectResult) => {
  //         Log.info(this.TAG, 'DocumentViewPicker.select successfully, DocumentSelectResult uri: ' + JSON.stringify(documentSelectResult));
  //
  //         if (documentSelectResult && documentSelectResult.length > 0) {
  //           let filePath = documentSelectResult[0];
  //           Log.info(this.TAG, 'DocumentViewPicker.select successfully, DocumentSelectResult uri: ' + filePath);
  //           return filePath;
  //         }
  //
  //       }).catch((err) => {
  //         Log.error(this.TAG, 'PhotoViewPicker.select failed with err: ' + err);
  //         return err;
  //       }).then(async (filePath) => {
  //
  //         const mediaBean = await this.buildMediaBean(filePath);
  //         return mediaBean;
  //
  //       });
  //   } catch (err) {
  //     Log.error(this.TAG, 'PhotoViewPicker failed with err: ' + err);
  //     return Promise.reject(err);
  //   }
  // }


  /**
   * 拍照
   */
  public async takePhoto(context: common.UIAbilityContext): Promise<MediaBean> {


    let want = {
      'uri': '',
      'action': wantConstant.Action.ACTION_IMAGE_CAPTURE,
      'parameters': {},
    };
    return context.startAbilityForResult(want)
      .then((result) => {
        Log.info(this.TAG, `startAbility call back , ${JSON.stringify(result)}`);
        if (result.resultCode === 0 && result.want && StringUtils.isNotNullOrEmpty(result.want.uri)) {
          //拍照成功
          Log.info(this.TAG, 'takePhoto successfully, takePhotoResult uri: ' + result.want.uri);
          return result.want.uri;
        }
      }).catch((error) => {
        Log.info(this.TAG, `startAbility error , ${JSON.stringify(error)}`);
        return error;
      }).then(async (uri: string) => {
        const mediaBean: MediaBean = new MediaBean();
        mediaBean.localUrl = uri;
        // const mediaBean = await this.buildMediaBean(uri);
        return mediaBean;
      });
  }


  /**
   * 封装多媒体实体类
   *
   * @param uri 文件路径
   */
  private async buildMediaBean(uri: string): Promise<MediaBean> {

    if (StringUtils.isNullOrEmpty(uri)) {
      return null;
    }

    const mediaBean: MediaBean = new MediaBean();
    mediaBean.localUrl = uri;
    // await this.appendFileInfoToMediaBean(mediaBean, uri);
    Log.info(this.TAG, 'DocumentViewPicker.select successfully, DocumentSelectResult uri: '+mediaBean)
    return mediaBean;
  }

  /**
   * 通过Uri查找所选文件信息，插入到MediaBean中
   * @param mediaBean
   * @param uri
   */
//   private async appendFileInfoToMediaBean(mediaBean: MediaBean, uri: string) {
//
//     if (StringUtils.isNullOrEmpty(uri)) {
//       return;
//     }
//     let fileList: Array<mediaLibrary.FileAsset> = [];
//
//     const parts: string[] = uri.split('/');
//     const id: string = parts.length > 0 ? parts[parts.length - 1] : '-1';
//
//     try {
//
//       let media = mediaLibrary.getMediaLibrary(this.mContext);
//       let mediaFetchOptions: mediaLibrary.MediaFetchOptions = {
//         selections: mediaLibrary.FileKey.ID + '= ?',
//         selectionArgs: [id],
//         uri: uri
//       };
//
//       let fetchFileResult = await media.getFileAssets(mediaFetchOptions);
//       Log.info(this.TAG, `fileList getFileAssetsFromType fetchFileResult.count = ${fetchFileResult.getCount()}`);
//       fileList = await fetchFileResult.getAllObject();
//       fetchFileResult.close();
//       await media.release();
//
//     } catch (e) {
//       Log.error(this.TAG, "query: file data  exception ");
//     }
//
//     if (fileList && fileList.length > 0) {
//
//       let fileInfoObj = fileList[0];
//       Log.info(this.TAG, `file id = ${JSON.stringify(fileInfoObj.id)} , uri = ${JSON.stringify(fileInfoObj.uri)}`);
//       Log.info(this.TAG, `file fileList displayName = ${fileInfoObj.displayName} ,size = ${fileInfoObj.size} ,mimeType = ${fileInfoObj.mimeType}`);
//
//       mediaBean.fileName = fileInfoObj.displayName;
//       mediaBean.fileSize = fileInfoObj.size;
//       mediaBean.fileType = fileInfoObj.mimeType;
//
//     }
//   }

  // //从文件读取内容
  // readContentFromFile(fileUri: string): ArrayBuffer {
  //   let file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
  //   let fsStat = fs.lstatSync(fileUri);
  //   let buf = new ArrayBuffer(fsStat.size);
  //   fs.readSync(file.fd, buf);
  //   fs.fsyncSync(file.fd)
  //   fs.closeSync(file);
  //   return buf
  // }

}