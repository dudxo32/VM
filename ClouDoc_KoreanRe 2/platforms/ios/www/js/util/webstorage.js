/********** Local Storage - single **********/
function SetlocalStorage(name, value) {
    localStorage.setItem(name, value);
}

function GetlocalStorage(name) {
    return localStorage.getItem(name);
}

function ClearlocalStorage(name) {
    localStorage.removeItem(name);
}

/********** Session Storage **********/
function SetsessionStorage(name, value) {
    sessionStorage.setItem(name, value);
}

function GetsessionStorage(name) {
    return sessionStorage.getItem(name);
}

function ClearsessionStorage(name) {
    sessionStorage.removeItem(name);
}
