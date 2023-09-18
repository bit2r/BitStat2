var ui_text =
{
    user_id: "User Id",
    password: "Password",
    login: "Login",
    cancel: "Cancel",
}

function l(in_text) {
    if (ui_text.hasOwnProperty(in_text)) {
        return ui_text[in_text];
    }
    return in_text;
}