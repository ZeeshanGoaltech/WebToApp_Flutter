/**
 * Patch auth/login/signup strings that were still English in locale JSON files.
 * Run: node tools/patch_auth_i18n.js && node tools/generate_i18n.js
 */
const fs = require('fs');
const path = require('path');

const I18N_DIR = path.join(__dirname, 'i18n');

const NEW_EN_KEYS = {
  auth_err_password_complexity:
    'Password must include 1 uppercase and 1 special character.',
  press_back_again_to_close: 'Press back again to close',
};

const PATCH = {
  af_za: {
    welcome: 'Welkom',
    create_account: 'Skep rekening',
    sign_in_subtitle: 'Meld aan om voort te gaan',
    sign_up_subtitle: 'Sluit aan en begin skep',
    email_label: 'E-pos',
    password_label: 'Wagwoord',
    password_hint: 'Voer jou wagwoord in',
    dont_have_account: "Het jy nie 'n rekening nie?",
    already_have_account: 'Het jy reeds \'n rekening?',
    password_reset_subtitle:
      'Voer jou e-pos in en ons stuur wagwoordherstel-instruksies as die rekening bestaan.',
    password_reset_send: 'Stuur herstelskakel',
    password_reset_sent: 'Gaan jou e-pos na',
    password_reset_sent_desc:
      'As \'n rekening bestaan, is wagwoordherstel-instruksies gestuur.',
    password_reset_email_required:
      'Voer jou e-posadres in om wagwoord te herstel.',
    auth_err_password_complexity:
      'Wagwoord moet 1 hoofletter en 1 spesiale karakter bevat.',
    press_back_again_to_close: 'Druk weer terug om te sluit',
  },
  ar_sa: {
    welcome: 'مرحباً',
    create_account: 'إنشاء حساب',
    sign_in_subtitle: 'سجّل الدخول لمتابعة رحلتك',
    sign_up_subtitle: 'انضم إلينا وابدأ الإنشاء',
    email_label: 'البريد الإلكتروني',
    password_label: 'كلمة المرور',
    password_hint: 'أدخل كلمة المرور',
    dont_have_account: 'ليس لديك حساب؟',
    already_have_account: 'هل لديك حساب بالفعل؟',
    password_reset_subtitle:
      'أدخل بريدك الإلكتروني وسنرسل تعليمات إعادة تعيين كلمة المرور إذا كان الحساب موجوداً.',
    password_reset_send: 'إرسال رابط إعادة التعيين',
    password_reset_sent: 'تحقق من بريدك الإلكتروني',
    password_reset_sent_desc:
      'إذا كان الحساب موجوداً، فقد تم إرسال تعليمات إعادة تعيين كلمة المرور.',
    password_reset_email_required:
      'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور.',
    auth_err_password_complexity:
      'يجب أن تتضمن كلمة المرور حرفاً كبيراً واحداً ورمزاً خاصاً واحداً.',
    press_back_again_to_close: 'اضغط رجوع مرة أخرى للإغلاق',
  },
  bn_bd: {
    welcome: 'স্বাগতম',
    create_account: 'অ্যাকাউন্ট তৈরি করুন',
    sign_in_subtitle: 'চালিয়ে যেতে সাইন ইন করুন',
    sign_up_subtitle: 'যোগ দিন এবং তৈরি শুরু করুন',
    email_label: 'ইমেইল',
    password_label: 'পাসওয়ার্ড',
    password_hint: 'আপনার পাসওয়ার্ড লিখুন',
    dont_have_account: 'অ্যাকাউন্ট নেই?',
    already_have_account: 'ইতিমধ্যে অ্যাকাউন্ট আছে?',
    password_reset_subtitle:
      'আপনার ইমেইল লিখুন এবং অ্যাকাউন্ট থাকলে আমরা পাসওয়ার্ড রিসেট নির্দেশনা পাঠাব।',
    password_reset_send: 'রিসেট লিংক পাঠান',
    password_reset_sent: 'আপনার ইমেইল দেখুন',
    password_reset_sent_desc:
      'অ্যাকাউন্ট থাকলে পাসওয়ার্ড রিসেট নির্দেশনা পাঠানো হয়েছে।',
    password_reset_email_required:
      'পাসওয়ার্ড রিসেট করতে আপনার ইমেইল লিখুন।',
    auth_err_password_complexity:
      'পাসওয়ার্ডে ১টি বড় হাতের অক্ষর এবং ১টি বিশেষ চিহ্ন থাকতে হবে।',
    press_back_again_to_close: 'বন্ধ করতে আবার ব্যাক চাপুন',
  },
  de_de: {
    welcome: 'Willkommen',
    create_account: 'Konto erstellen',
    sign_in_subtitle: 'Melde dich an, um fortzufahren',
    sign_up_subtitle: 'Tritt bei und beginne zu erstellen',
    email_label: 'E-Mail',
    password_label: 'Passwort',
    password_hint: 'Passwort eingeben',
    dont_have_account: 'Noch kein Konto?',
    already_have_account: 'Bereits ein Konto?',
    password_reset_subtitle:
      'Gib deine E-Mail ein. Wenn ein Konto existiert, senden wir Anweisungen zum Zurücksetzen.',
    password_reset_send: 'Link zum Zurücksetzen senden',
    password_reset_sent: 'E-Mail prüfen',
    password_reset_sent_desc:
      'Falls ein Konto existiert, wurden Anweisungen zum Zurücksetzen gesendet.',
    password_reset_email_required:
      'Gib deine E-Mail-Adresse ein, um das Passwort zurückzusetzen.',
    auth_err_password_complexity:
      'Das Passwort muss 1 Großbuchstaben und 1 Sonderzeichen enthalten.',
    press_back_again_to_close: 'Zum Schließen erneut Zurück drücken',
  },
  es_ar: {
    welcome: 'Bienvenido',
    create_account: 'Crear cuenta',
    sign_in_subtitle: 'Inicia sesión para continuar',
    sign_up_subtitle: 'Únete y empieza a crear',
    email_label: 'Correo electrónico',
    password_label: 'Contraseña',
    password_hint: 'Ingresa tu contraseña',
    dont_have_account: '¿No tienes cuenta?',
    already_have_account: '¿Ya tienes cuenta?',
    password_reset_subtitle:
      'Ingresa tu correo y te enviaremos instrucciones si la cuenta existe.',
    password_reset_send: 'Enviar enlace de restablecimiento',
    password_reset_sent: 'Revisa tu correo',
    password_reset_sent_desc:
      'Si la cuenta existe, se enviaron instrucciones para restablecer la contraseña.',
    password_reset_email_required:
      'Ingresa tu correo para restablecer la contraseña.',
    auth_err_password_complexity:
      'La contraseña debe incluir 1 mayúscula y 1 carácter especial.',
    press_back_again_to_close: 'Presiona atrás otra vez para cerrar',
  },
  es_co: {
    welcome: 'Bienvenido',
    create_account: 'Crear cuenta',
    sign_in_subtitle: 'Inicia sesión para continuar',
    sign_up_subtitle: 'Únete y empieza a crear',
    email_label: 'Correo electrónico',
    password_label: 'Contraseña',
    password_hint: 'Ingresa tu contraseña',
    dont_have_account: '¿No tienes cuenta?',
    already_have_account: '¿Ya tienes cuenta?',
    password_reset_subtitle:
      'Ingresa tu correo y te enviaremos instrucciones si la cuenta existe.',
    password_reset_send: 'Enviar enlace de restablecimiento',
    password_reset_sent: 'Revisa tu correo',
    password_reset_sent_desc:
      'Si la cuenta existe, se enviaron instrucciones para restablecer la contraseña.',
    password_reset_email_required:
      'Ingresa tu correo para restablecer la contraseña.',
    auth_err_password_complexity:
      'La contraseña debe incluir 1 mayúscula y 1 carácter especial.',
    press_back_again_to_close: 'Presiona atrás otra vez para cerrar',
  },
  es_es: {
    welcome: 'Bienvenido',
    create_account: 'Crear cuenta',
    sign_in_subtitle: 'Inicia sesión para continuar',
    sign_up_subtitle: 'Únete y empieza a crear',
    email_label: 'Correo electrónico',
    password_label: 'Contraseña',
    password_hint: 'Introduce tu contraseña',
    dont_have_account: '¿No tienes cuenta?',
    already_have_account: '¿Ya tienes cuenta?',
    password_reset_subtitle:
      'Introduce tu correo y te enviaremos instrucciones si la cuenta existe.',
    password_reset_send: 'Enviar enlace de restablecimiento',
    password_reset_sent: 'Revisa tu correo',
    password_reset_sent_desc:
      'Si la cuenta existe, se enviaron instrucciones para restablecer la contraseña.',
    password_reset_email_required:
      'Introduce tu correo para restablecer la contraseña.',
    auth_err_password_complexity:
      'La contraseña debe incluir 1 mayúscula y 1 carácter especial.',
    press_back_again_to_close: 'Pulsa atrás otra vez para cerrar',
  },
  es_mx: {
    welcome: 'Bienvenido',
    create_account: 'Crear cuenta',
    sign_in_subtitle: 'Inicia sesión para continuar',
    sign_up_subtitle: 'Únete y empieza a crear',
    email_label: 'Correo electrónico',
    password_label: 'Contraseña',
    password_hint: 'Ingresa tu contraseña',
    dont_have_account: '¿No tienes cuenta?',
    already_have_account: '¿Ya tienes cuenta?',
    password_reset_subtitle:
      'Ingresa tu correo y te enviaremos instrucciones si la cuenta existe.',
    password_reset_send: 'Enviar enlace de restablecimiento',
    password_reset_sent: 'Revisa tu correo',
    password_reset_sent_desc:
      'Si la cuenta existe, se enviaron instrucciones para restablecer la contraseña.',
    password_reset_email_required:
      'Ingresa tu correo para restablecer la contraseña.',
    auth_err_password_complexity:
      'La contraseña debe incluir 1 mayúscula y 1 carácter especial.',
    press_back_again_to_close: 'Presiona atrás otra vez para cerrar',
  },
  fa_ir: {
    welcome: 'خوش آمدید',
    create_account: 'ایجاد حساب',
    sign_in_subtitle: 'برای ادامه وارد شوید',
    sign_up_subtitle: 'به ما بپیوندید و شروع به ساخت کنید',
    email_label: 'ایمیل',
    password_label: 'رمز عبور',
    password_hint: 'رمز عبور خود را وارد کنید',
    dont_have_account: 'حساب کاربری ندارید؟',
    already_have_account: 'قبلاً حساب دارید؟',
    password_reset_subtitle:
      'ایمیل خود را وارد کنید؛ اگر حساب وجود داشته باشد، دستورالعمل بازیابی ارسال می‌شود.',
    password_reset_send: 'ارسال لینک بازیابی',
    password_reset_sent: 'ایمیل خود را بررسی کنید',
    password_reset_sent_desc:
      'اگر حساب وجود داشته باشد، دستورالعمل بازیابی رمز عبور ارسال شده است.',
    password_reset_email_required:
      'برای بازیابی رمز عبور، ایمیل خود را وارد کنید.',
    auth_err_password_complexity:
      'رمز عبور باید شامل ۱ حرف بزرگ و ۱ نویسهٔ ویژه باشد.',
    press_back_again_to_close: 'برای بستن دوباره بازگشت را بزنید',
  },
  fil_ph: {
    welcome: 'Maligayang pagdating',
    create_account: 'Gumawa ng account',
    sign_in_subtitle: 'Mag-sign in para magpatuloy',
    sign_up_subtitle: 'Sumali at magsimulang gumawa',
    email_label: 'Email',
    email_address: 'Email address',
    password_label: 'Password',
    password_hint: 'Ilagay ang iyong password',
    dont_have_account: 'Wala pang account?',
    already_have_account: 'May account ka na ba?',
    guest_user: 'Guest User',
    password_reset_subtitle:
      'Ilagay ang email mo at magpapadala kami ng reset instructions kung may account.',
    password_reset_send: 'Ipadala ang reset link',
    password_reset_sent: 'Tingnan ang email mo',
    password_reset_sent_desc:
      'Kung may account, naipadala na ang password reset instructions.',
    password_reset_email_required:
      'Ilagay ang email mo para i-reset ang password.',
    auth_err_password_complexity:
      'Dapat may 1 uppercase at 1 special character ang password.',
    press_back_again_to_close: 'Pindutin muli ang back para isara',
  },
  fr_fr: {
    welcome: 'Bienvenue',
    create_account: 'Créer un compte',
    sign_in_subtitle: 'Connectez-vous pour continuer',
    sign_up_subtitle: 'Rejoignez-nous et commencez à créer',
    email_label: 'E-mail',
    password_label: 'Mot de passe',
    password_hint: 'Entrez votre mot de passe',
    dont_have_account: 'Pas de compte ?',
    already_have_account: 'Vous avez déjà un compte ?',
    password_reset_subtitle:
      'Entrez votre e-mail. Si le compte existe, nous enverrons les instructions.',
    password_reset_send: 'Envoyer le lien de réinitialisation',
    password_reset_sent: 'Vérifiez votre e-mail',
    password_reset_sent_desc:
      'Si un compte existe, les instructions de réinitialisation ont été envoyées.',
    password_reset_email_required:
      'Entrez votre e-mail pour réinitialiser le mot de passe.',
    auth_err_password_complexity:
      'Le mot de passe doit inclure 1 majuscule et 1 caractère spécial.',
    press_back_again_to_close: 'Appuyez à nouveau sur retour pour fermer',
  },
  hi_in: {
    welcome: 'स्वागत है',
    create_account: 'खाता बनाएं',
    sign_in_subtitle: 'जारी रखने के लिए साइन इन करें',
    sign_up_subtitle: 'जुड़ें और बनाना शुरू करें',
    email_label: 'ईमेल',
    password_label: 'पासवर्ड',
    password_hint: 'अपना पासवर्ड दर्ज करें',
    dont_have_account: 'खाता नहीं है?',
    already_have_account: 'पहले से खाता है?',
    password_reset_subtitle:
      'अपना ईमेल दर्ज करें; यदि खाता मौजूद है तो हम रीसेट निर्देश भेजेंगे।',
    password_reset_send: 'रीसेट लिंक भेजें',
    password_reset_sent: 'अपना ईमेल देखें',
    password_reset_sent_desc:
      'यदि खाता मौजूद है, तो पासवर्ड रीसेट निर्देश भेज दिए गए हैं।',
    password_reset_email_required:
      'पासवर्ड रीसेट करने के लिए अपना ईमेल दर्ज करें।',
    auth_err_password_complexity:
      'पासवर्ड में 1 बड़ा अक्षर और 1 विशेष वर्ण होना चाहिए।',
    press_back_again_to_close: 'बंद करने के लिए फिर से बैक दबाएं',
  },
  id_id: {
    welcome: 'Selamat datang',
    create_account: 'Buat akun',
    sign_in_subtitle: 'Masuk untuk melanjutkan',
    sign_up_subtitle: 'Bergabung dan mulai membuat',
    email_label: 'Email',
    password_label: 'Kata sandi',
    password_hint: 'Masukkan kata sandi Anda',
    dont_have_account: 'Belum punya akun?',
    already_have_account: 'Sudah punya akun?',
    password_reset_subtitle:
      'Masukkan email Anda. Jika akun ada, kami akan kirim instruksi reset.',
    password_reset_send: 'Kirim tautan reset',
    password_reset_sent: 'Periksa email Anda',
    password_reset_sent_desc:
      'Jika akun ada, instruksi reset kata sandi telah dikirim.',
    password_reset_email_required:
      'Masukkan email untuk mereset kata sandi.',
    auth_err_password_complexity:
      'Kata sandi harus memiliki 1 huruf besar dan 1 karakter khusus.',
    press_back_again_to_close: 'Tekan kembali lagi untuk menutup',
  },
  it_it: {
    welcome: 'Benvenuto',
    create_account: 'Crea account',
    sign_in_subtitle: 'Accedi per continuare',
    sign_up_subtitle: 'Unisciti a noi e inizia a creare',
    email_label: 'Email',
    password_label: 'Password',
    password_hint: 'Inserisci la password',
    dont_have_account: 'Non hai un account?',
    already_have_account: 'Hai già un account?',
    password_reset_subtitle:
      'Inserisci la tua email. Se l\'account esiste, invieremo le istruzioni.',
    password_reset_send: 'Invia link di reimpostazione',
    password_reset_sent: 'Controlla la tua email',
    password_reset_sent_desc:
      'Se l\'account esiste, le istruzioni di reimpostazione sono state inviate.',
    password_reset_email_required:
      'Inserisci la tua email per reimpostare la password.',
    auth_err_password_complexity:
      'La password deve includere 1 maiuscola e 1 carattere speciale.',
    press_back_again_to_close: 'Premi di nuovo indietro per chiudere',
  },
  ja_jp: {
    welcome: 'ようこそ',
    create_account: 'アカウント作成',
    sign_in_subtitle: '続行するにはサインイン',
    sign_up_subtitle: '参加して作成を始めましょう',
    email_label: 'メール',
    password_label: 'パスワード',
    password_hint: 'パスワードを入力',
    dont_have_account: 'アカウントをお持ちでないですか？',
    already_have_account: 'すでにアカウントをお持ちですか？',
    password_reset_subtitle:
      'メールを入力してください。アカウントが存在する場合、再設定手順を送信します。',
    password_reset_send: '再設定リンクを送信',
    password_reset_sent: 'メールを確認してください',
    password_reset_sent_desc:
      'アカウントが存在する場合、パスワード再設定手順を送信しました。',
    password_reset_email_required:
      'パスワードを再設定するにはメールを入力してください。',
    auth_err_password_complexity:
      'パスワードには大文字1文字と特殊文字1つを含めてください。',
    press_back_again_to_close: 'もう一度戻るを押して閉じる',
  },
  ko_kr: {
    welcome: '환영합니다',
    create_account: '계정 만들기',
    sign_in_subtitle: '계속하려면 로그인하세요',
    sign_up_subtitle: '가입하고 만들기를 시작하세요',
    email_label: '이메일',
    password_label: '비밀번호',
    password_hint: '비밀번호를 입력하세요',
    dont_have_account: '계정이 없으신가요?',
    already_have_account: '이미 계정이 있으신가요?',
    password_reset_subtitle:
      '이메일을 입력하세요. 계정이 있으면 재설정 안내를 보내드립니다.',
    password_reset_send: '재설정 링크 보내기',
    password_reset_sent: '이메일을 확인하세요',
    password_reset_sent_desc:
      '계정이 있으면 비밀번호 재설정 안내가 전송되었습니다.',
    password_reset_email_required:
      '비밀번호를 재설정하려면 이메일을 입력하세요.',
    auth_err_password_complexity:
      '비밀번호에는 대문자 1개와 특수문자 1개가 포함되어야 합니다.',
    press_back_again_to_close: '닫으려면 뒤로를 한 번 더 누르세요',
  },
  ms_my: {
    welcome: 'Selamat datang',
    create_account: 'Cipta akaun',
    sign_in_subtitle: 'Log masuk untuk teruskan',
    sign_up_subtitle: 'Sertai kami dan mula mencipta',
    email_label: 'E-mel',
    password_label: 'Kata laluan',
    password_hint: 'Masukkan kata laluan anda',
    dont_have_account: 'Tiada akaun?',
    already_have_account: 'Sudah ada akaun?',
    password_reset_subtitle:
      'Masukkan e-mel anda. Jika akaun wujud, kami akan hantar arahan tetapan semula.',
    password_reset_send: 'Hantar pautan tetapan semula',
    password_reset_sent: 'Semak e-mel anda',
    password_reset_sent_desc:
      'Jika akaun wujud, arahan tetapan semula kata laluan telah dihantar.',
    password_reset_email_required:
      'Masukkan e-mel anda untuk tetapkan semula kata laluan.',
    auth_err_password_complexity:
      'Kata laluan mesti mengandungi 1 huruf besar dan 1 aksara khas.',
    press_back_again_to_close: 'Tekan kembali sekali lagi untuk tutup',
  },
  nl_nl: {
    welcome: 'Welkom',
    create_account: 'Account aanmaken',
    sign_in_subtitle: 'Log in om verder te gaan',
    sign_up_subtitle: 'Doe mee en begin met maken',
    email_label: 'E-mail',
    password_label: 'Wachtwoord',
    password_hint: 'Voer je wachtwoord in',
    dont_have_account: 'Geen account?',
    already_have_account: 'Heb je al een account?',
    password_reset_subtitle:
      'Voer je e-mail in. Als het account bestaat, sturen we resetinstructies.',
    password_reset_send: 'Resetlink verzenden',
    password_reset_sent: 'Controleer je e-mail',
    password_reset_sent_desc:
      'Als het account bestaat, zijn resetinstructies verzonden.',
    password_reset_email_required:
      'Voer je e-mail in om het wachtwoord te resetten.',
    auth_err_password_complexity:
      'Wachtwoord moet 1 hoofdletter en 1 speciaal teken bevatten.',
    press_back_again_to_close: 'Druk nogmaals op terug om te sluiten',
  },
  pl_pl: {
    welcome: 'Witamy',
    create_account: 'Utwórz konto',
    sign_in_subtitle: 'Zaloguj się, aby kontynuować',
    sign_up_subtitle: 'Dołącz do nas i zacznij tworzyć',
    email_label: 'E-mail',
    password_label: 'Hasło',
    password_hint: 'Wprowadź hasło',
    dont_have_account: 'Nie masz konta?',
    already_have_account: 'Masz już konto?',
    password_reset_subtitle:
      'Wprowadź e-mail. Jeśli konto istnieje, wyślemy instrukcje resetowania.',
    password_reset_send: 'Wyślij link resetujący',
    password_reset_sent: 'Sprawdź e-mail',
    password_reset_sent_desc:
      'Jeśli konto istnieje, wysłano instrukcje resetowania hasła.',
    password_reset_email_required:
      'Wprowadź e-mail, aby zresetować hasło.',
    auth_err_password_complexity:
      'Hasło musi zawierać 1 wielką literę i 1 znak specjalny.',
    press_back_again_to_close: 'Naciśnij wstecz ponownie, aby zamknąć',
  },
  pt_br: {
    welcome: 'Bem-vindo',
    create_account: 'Criar conta',
    sign_in_subtitle: 'Entre para continuar',
    sign_up_subtitle: 'Junte-se a nós e comece a criar',
    email_label: 'E-mail',
    password_label: 'Senha',
    password_hint: 'Digite sua senha',
    dont_have_account: 'Não tem conta?',
    already_have_account: 'Já tem conta?',
    password_reset_subtitle:
      'Digite seu e-mail. Se a conta existir, enviaremos instruções de redefinição.',
    password_reset_send: 'Enviar link de redefinição',
    password_reset_sent: 'Verifique seu e-mail',
    password_reset_sent_desc:
      'Se a conta existir, as instruções de redefinição foram enviadas.',
    password_reset_email_required:
      'Digite seu e-mail para redefinir a senha.',
    auth_err_password_complexity:
      'A senha deve incluir 1 letra maiúscula e 1 caractere especial.',
    press_back_again_to_close: 'Pressione voltar novamente para fechar',
  },
  pt_pt: {
    welcome: 'Bem-vindo',
    create_account: 'Criar conta',
    sign_in_subtitle: 'Inicie sessão para continuar',
    sign_up_subtitle: 'Junte-se a nós e comece a criar',
    email_label: 'E-mail',
    password_label: 'Palavra-passe',
    password_hint: 'Introduza a sua palavra-passe',
    dont_have_account: 'Não tem conta?',
    already_have_account: 'Já tem conta?',
    password_reset_subtitle:
      'Introduza o seu e-mail. Se a conta existir, enviaremos instruções.',
    password_reset_send: 'Enviar ligação de redefinição',
    password_reset_sent: 'Verifique o seu e-mail',
    password_reset_sent_desc:
      'Se a conta existir, foram enviadas instruções de redefinição.',
    password_reset_email_required:
      'Introduza o seu e-mail para redefinir a palavra-passe.',
    auth_err_password_complexity:
      'A palavra-passe deve incluir 1 maiúscula e 1 carácter especial.',
    press_back_again_to_close: 'Prima voltar novamente para fechar',
  },
  ru_ru: {
    welcome: 'Добро пожаловать',
    create_account: 'Создать аккаунт',
    sign_in_subtitle: 'Войдите, чтобы продолжить',
    sign_up_subtitle: 'Присоединяйтесь и начните создавать',
    email_label: 'Эл. почта',
    password_label: 'Пароль',
    password_hint: 'Введите пароль',
    dont_have_account: 'Нет аккаунта?',
    already_have_account: 'Уже есть аккаунт?',
    password_reset_subtitle:
      'Введите email. Если аккаунт существует, мы отправим инструкции.',
    password_reset_send: 'Отправить ссылку для сброса',
    password_reset_sent: 'Проверьте почту',
    password_reset_sent_desc:
      'Если аккаунт существует, инструкции по сбросу пароля отправлены.',
    password_reset_email_required:
      'Введите email для сброса пароля.',
    auth_err_password_complexity:
      'Пароль должен содержать 1 заглавную букву и 1 спецсимвол.',
    press_back_again_to_close: 'Нажмите назад ещё раз, чтобы закрыть',
  },
  sv_se: {
    welcome: 'Välkommen',
    create_account: 'Skapa konto',
    sign_in_subtitle: 'Logga in för att fortsätta',
    sign_up_subtitle: 'Gå med och börja skapa',
    email_label: 'E-post',
    password_label: 'Lösenord',
    password_hint: 'Ange ditt lösenord',
    dont_have_account: 'Inget konto?',
    already_have_account: 'Har du redan ett konto?',
    password_reset_subtitle:
      'Ange din e-post. Om kontot finns skickar vi återställningsinstruktioner.',
    password_reset_send: 'Skicka återställningslänk',
    password_reset_sent: 'Kontrollera din e-post',
    password_reset_sent_desc:
      'Om kontot finns har återställningsinstruktioner skickats.',
    password_reset_email_required:
      'Ange din e-post för att återställa lösenordet.',
    auth_err_password_complexity:
      'Lösenordet måste innehålla 1 versal och 1 specialtecken.',
    press_back_again_to_close: 'Tryck tillbaka igen för att stänga',
  },
  th_th: {
    welcome: 'ยินดีต้อนรับ',
    create_account: 'สร้างบัญชี',
    sign_in_subtitle: 'เข้าสู่ระบบเพื่อดำเนินการต่อ',
    sign_up_subtitle: 'เข้าร่วมและเริ่มสร้าง',
    email_label: 'อีเมล',
    password_label: 'รหัสผ่าน',
    password_hint: 'ใส่รหัสผ่านของคุณ',
    dont_have_account: 'ยังไม่มีบัญชี?',
    already_have_account: 'มีบัญชีอยู่แล้ว?',
    password_reset_subtitle:
      'ใส่อีเมลของคุณ หากมีบัญชี เราจะส่งคำแนะนำการรีเซ็ตรหัสผ่าน',
    password_reset_send: 'ส่งลิงก์รีเซ็ต',
    password_reset_sent: 'ตรวจสอบอีเมลของคุณ',
    password_reset_sent_desc:
      'หากมีบัญชี ได้ส่งคำแนะนำการรีเซ็ตรหัสผ่านแล้ว',
    password_reset_email_required:
      'ใส่อีเมลเพื่อรีเซ็ตรหัสผ่าน',
    auth_err_password_complexity:
      'รหัสผ่านต้องมีตัวพิมพ์ใหญ่ 1 ตัวและอักขระพิเศษ 1 ตัว',
    press_back_again_to_close: 'กดกลับอีกครั้งเพื่อปิด',
  },
  tr_tr: {
    welcome: 'Hoş geldiniz',
    create_account: 'Hesap oluştur',
    sign_in_subtitle: 'Devam etmek için giriş yapın',
    sign_up_subtitle: 'Katılın ve oluşturmaya başlayın',
    email_label: 'E-posta',
    password_label: 'Şifre',
    password_hint: 'Şifrenizi girin',
    dont_have_account: 'Hesabınız yok mu?',
    already_have_account: 'Zaten hesabınız var mı?',
    password_reset_subtitle:
      'E-postanızı girin. Hesap varsa sıfırlama talimatları gönderilecektir.',
    password_reset_send: 'Sıfırlama bağlantısı gönder',
    password_reset_sent: 'E-postanızı kontrol edin',
    password_reset_sent_desc:
      'Hesap varsa şifre sıfırlama talimatları gönderildi.',
    password_reset_email_required:
      'Şifreyi sıfırlamak için e-postanızı girin.',
    auth_err_password_complexity:
      'Şifre 1 büyük harf ve 1 özel karakter içermelidir.',
    press_back_again_to_close: 'Kapatmak için tekrar geri basın',
  },
  uk_ua: {
    welcome: 'Ласкаво просимо',
    create_account: 'Створити обліковий запис',
    sign_in_subtitle: 'Увійдіть, щоб продовжити',
    sign_up_subtitle: 'Приєднуйтесь і починайте створювати',
    email_label: 'Ел. пошта',
    password_label: 'Пароль',
    password_hint: 'Введіть пароль',
    dont_have_account: 'Немає облікового запису?',
    already_have_account: 'Уже маєте обліковий запис?',
    password_reset_subtitle:
      'Введіть email. Якщо обліковий запис існує, ми надішлемо інструкції.',
    password_reset_send: 'Надіслати посилання для скидання',
    password_reset_sent: 'Перевірте пошту',
    password_reset_sent_desc:
      'Якщо обліковий запис існує, інструкції зі скидання пароля надіслано.',
    password_reset_email_required:
      'Введіть email для скидання пароля.',
    auth_err_password_complexity:
      'Пароль має містити 1 велику літеру та 1 спецсимвол.',
    press_back_again_to_close: 'Натисніть назад ще раз, щоб закрити',
  },
  uz_uz: {
    welcome: 'Xush kelibsiz',
    create_account: 'Hisob yaratish',
    sign_in_subtitle: 'Davom etish uchun tizimga kiring',
    sign_up_subtitle: "Qo'shiling va yaratishni boshlang",
    email_label: 'Email',
    password_label: 'Parol',
    password_hint: 'Parolingizni kiriting',
    dont_have_account: 'Hisobingiz yo\'qmi?',
    already_have_account: 'Allaqachon hisobingiz bormi?',
    password_reset_subtitle:
      'Emailingizni kiriting. Hisob mavjud bo\'lsa, tiklash ko\'rsatmalarini yuboramiz.',
    password_reset_send: 'Tiklash havolasini yuborish',
    password_reset_sent: 'Emailingizni tekshiring',
    password_reset_sent_desc:
      'Hisob mavjud bo\'lsa, parolni tiklash ko\'rsatmalari yuborildi.',
    password_reset_email_required:
      'Parolni tiklash uchun emailingizni kiriting.',
    auth_err_password_complexity:
      'Parol 1 ta katta harf va 1 ta maxsus belgini o\'z ichiga olishi kerak.',
    press_back_again_to_close: 'Yopish uchun yana orqaga bosing',
  },
  vi_vn: {
    welcome: 'Chào mừng',
    create_account: 'Tạo tài khoản',
    sign_in_subtitle: 'Đăng nhập để tiếp tục',
    sign_up_subtitle: 'Tham gia và bắt đầu tạo',
    email_label: 'Email',
    password_label: 'Mật khẩu',
    password_hint: 'Nhập mật khẩu của bạn',
    dont_have_account: 'Chưa có tài khoản?',
    already_have_account: 'Đã có tài khoản?',
    password_reset_subtitle:
      'Nhập email của bạn. Nếu tài khoản tồn tại, chúng tôi sẽ gửi hướng dẫn.',
    password_reset_send: 'Gửi liên kết đặt lại',
    password_reset_sent: 'Kiểm tra email của bạn',
    password_reset_sent_desc:
      'Nếu tài khoản tồn tại, hướng dẫn đặt lại mật khẩu đã được gửi.',
    password_reset_email_required:
      'Nhập email để đặt lại mật khẩu.',
    auth_err_password_complexity:
      'Mật khẩu phải có 1 chữ hoa và 1 ký tự đặc biệt.',
    press_back_again_to_close: 'Nhấn quay lại lần nữa để đóng',
  },
  zh_cn: {
    welcome: '欢迎',
    create_account: '创建账户',
    sign_in_subtitle: '登录以继续',
    sign_up_subtitle: '加入我们，开始创建',
    email_label: '邮箱',
    password_label: '密码',
    password_hint: '请输入密码',
    dont_have_account: '还没有账户？',
    already_have_account: '已有账户？',
    password_reset_subtitle:
      '输入邮箱，如果账户存在，我们将发送重置说明。',
    password_reset_send: '发送重置链接',
    password_reset_sent: '请查收邮件',
    password_reset_sent_desc:
      '如果账户存在，密码重置说明已发送。',
    password_reset_email_required:
      '请输入邮箱以重置密码。',
    auth_err_password_complexity:
      '密码必须包含1个大写字母和1个特殊字符。',
    press_back_again_to_close: '再按一次返回键关闭',
  },
};

function patchLocale(localeId, data, patch) {
  let changed = 0;
  for (const [key, value] of Object.entries(patch)) {
    if (data[key] !== value) {
      data[key] = value;
      changed++;
    }
  }
  return changed;
}

// English base files
for (const locale of ['en_us', 'en_gb']) {
  const filePath = path.join(I18N_DIR, `${locale}.json`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const changed = patchLocale(locale, data, NEW_EN_KEYS);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n', 'utf8');
  console.log(`${locale}: +${changed} keys`);
}

for (const [locale, patch] of Object.entries(PATCH)) {
  const filePath = path.join(I18N_DIR, `${locale}.json`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const merged = { ...NEW_EN_KEYS, ...patch };
  const changed = patchLocale(locale, data, merged);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n', 'utf8');
  console.log(`${locale}: updated ${changed} keys`);
}

console.log('Done. Run: node tools/generate_i18n.js');
