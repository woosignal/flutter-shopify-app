import 'package:nylo_framework/nylo_framework.dart';

/* Register Form
|--------------------------------------------------------------------------
| Usage: https://nylo.dev/docs/6.x/forms#how-it-works
| Casts: https://nylo.dev/docs/6.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/6.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class RegisterForm extends NyFormData {
  RegisterForm({String? name}) : super(name ?? "register");

  @override
  fields() => [
        [
          Field.text("First Name",
              style: "compact", validate: FormValidator.maxLength(100)),
          Field.text("Last Name",
              style: "compact", validate: FormValidator.maxLength(100)),
        ],
        Field.email("Email Address",
            style: "compact", validate: FormValidator.email()),
        Field.password("Password",
            style: "compact",
            viewable: true,
            validate: FormValidator.password()),
      ];
}
