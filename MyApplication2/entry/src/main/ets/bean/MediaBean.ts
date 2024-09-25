import image from '@ohos.multimedia.image'
import { DetectionBoxes } from '../bean/DetectResult'
/**
 * 多媒体数据类
 */
export class MediaBean {
  /**
   * 文件名称
   */
  public fileName: string;
  /**
   * 文件大小
   */
  // public fileSize: number;
  /**
   * 文件类型
   */
  // public fileType: string;
  /**
   * 本地存储地址
   */
  public localUrl: string;
  /**
   * 检测结果
   */
  public result: string;
  /**
   * 检测类别
   */
  public detection_classes: string[];
  /**
   * 检测矩形框
   */
  public detection_boxes: number[][];
  /**
   * 检测置信度
   */
  public detection_scores: number[];
  /**
   * 检测后图片
   */
  public detection_image?: image.PixelMap;
  /**
   * 序号
   */
  public No: number;

}

