// 個別のファイルに切り出すほどではない関数の定義のためここに書いている
$(function () {
  let confirm = document.getElementById('password_confirmation')

  // TODO: validatorとしてutil化する
  // バリデーションメッセージが表示され続けてしまうのを回避する
  $("#password, #password_confirmation").on('change', () => {
    confirm.setCustomValidity('')
    confirm.reportValidity()
  })

  // TODO:パスワード6文字以上制限について
  $("#reset-form").submit(function () {
    if ($("#password").val() !== $("#password_confirmation").val()) {
      confirm.setCustomValidity('entered and re-entered password does not match')
      confirm.reportValidity()
      return false;
    } else {
      confirm.setCustomValidity('')
    }
  })
});
