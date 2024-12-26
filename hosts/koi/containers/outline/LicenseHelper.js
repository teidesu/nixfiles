'use strict';

Object.defineProperty(exports, "__esModule", {
  'value': true
});

class LicenseHelper {
  static async updateLicenseStatus(_0x2921bc) {}
  static isOverSeatLimit = false;
  static isFarExceedingSeatLimit = false;
  static decoded = undefined;
  static get lastCheckedAt() { return new Date(); };
  static publicKey = '';

  static details() {
    return {
      'isOverSeatLimit': false,
      'isFarExceedingSeatLimit': false,
      'isMissing': false,
      'isInGracePeriod': false,
      'isValid': true,
      'isTrial': false,
      'licensedTo': 'catgirls :3',
      'expiresAt': new Date(2077, 0, 0),
      'gracePeriodExpiresAt': new Date(2077, 0, 0),
      'customerId': 'catgirls :3',
      'seatCount': 99999999
    };
  }
}

exports.default = LicenseHelper;