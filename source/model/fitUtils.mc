import Toybox.Lang;

// FIT string fields are created with :count => 50, which includes the null terminator.
const FIT_STRING_MAX = 49;

// A longer string makes setData fail with a System Error ("setData string too long for allocated space")
// that try/catch can't catch: the app stops and the activity isn't saved. Checked in the simulator:
// 49 characters work, 50 crash. So cut the string before writing it, keeping the start (the earliest sets).
// Assumes ASCII (one byte per character), which the score always is.
function fitString(s as String, max as Number) as String {
    if (s.length() > max) {
        return s.substring(0, max) as String;
    }
    return s;
}
