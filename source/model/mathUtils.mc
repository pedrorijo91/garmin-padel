import Toybox.Lang;

function min(x as Number, y as Number) as Number {
    if (x > y) {
        return y;
    } else {
        return x;
    }
}

function abs(x as Number) as Number {
    if (x > 0) {
        return x;
    } else {
        return x * -1;
    }
}