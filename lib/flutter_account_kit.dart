/// Reusable account features: auth, profile and settings.
library flutter_account_kit;

export 'src/core/account_strings.dart';
export 'src/core/account_theme.dart';
export 'src/core/auth_failure.dart';

export 'src/auth/auth_repository.dart';
export 'src/auth/auth_session.dart';
export 'src/auth/auth_providers.dart';
export 'src/auth/auth_flow_controller.dart';
export 'src/auth/email_password_screen.dart';
export 'src/auth/phone_otp_screen.dart';
export 'src/auth/widgets/otp_field.dart';

export 'src/profile/profile.dart';
export 'src/profile/profile_providers.dart';
export 'src/profile/profile_screen.dart';

export 'src/settings/settings_providers.dart';
export 'src/settings/settings_screen.dart';
