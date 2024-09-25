import http from '@ohos.net.http';

// 接口参数格式校验
interface ReqObj {
  url: string
  params?: object | string | number
}

export default async function getHttpData(reqObj:ReqObj): Promise<any>{
  let dataList: any = []

  let httpRequest = http.createHttp();
  let response = httpRequest.request(
    "https://infer-modelarts-cn-southwest-2.myhuaweicloud.com/v1/infers/c14ed7e8-13c5-4391-80fa-eb35d8b5e9b8",
    {
      // 接口请求method
      method: http.RequestMethod.POST,
      // 接口请求头
      header: {
        'Content-Type': 'application/json'
      },
      //使用POST请求时此字段用于传递内容
      extraData: {
        data: ''
      },
      // 可选，指定返回数据的类型
      expectDataType: http.HttpDataType.STRING,
    }
  );
  await response.then((data) => {
    const code = data.responseCode
    if (code == 200) {
      const response = data.result + "";
      const res = JSON.parse(response).data
      dataList = res
    }else if (code === 401){
      // 登录状态失效
    }
  }).catch((err) => {
    console.info('error:' + JSON.stringify(err));
  })
  return dataList;
}