-- Constants

APP_REPO = "ONElua"
APP_PROJECT = "ONEMenu-for-PSVita"
APP_VPK = "ONEMenuVita"

APP_VERSION_MAJOR = 0x02 -- major.minor
APP_VERSION_MINOR = 0x01

APP_VERSION = ((APP_VERSION_MAJOR << 0x18) | (APP_VERSION_MINOR << 0x10)) -- Union Binary
