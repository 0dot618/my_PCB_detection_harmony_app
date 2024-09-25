export class Log {
  public static info(tag: string, msg: string) {
    console.info(`${tag} ${msg}`);
  }

  public static error(tag: string, msg: string) {
    console.error(`${tag} ${msg}`);
  }
}