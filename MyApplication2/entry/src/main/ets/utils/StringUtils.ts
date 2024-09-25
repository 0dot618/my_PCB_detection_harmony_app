export class StringUtils {

  static isNullOrEmpty(value: string | null | undefined): boolean {
    return value === null || value === undefined || value === '' || value === 'null' || value === "null";
  }

  static isNotNullOrEmpty(value: string | null | undefined): boolean {
    return !this.isNullOrEmpty(value);
  }
}