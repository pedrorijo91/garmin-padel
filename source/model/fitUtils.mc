import Toybox.Lang;

// FIT string fields are created with :count => 50, which includes the null terminator.
const FIT_STRING_MAX = 49;

// setData throws if the string doesn't fit, and then the activity isn't saved.
// Keeps the start (the earliest sets) and drops the rest.
function fitString(s as String, max as Number) as String {
    if (s.length() > max) {
        return s.substring(0, max) as String;
    }
    return s;
}
