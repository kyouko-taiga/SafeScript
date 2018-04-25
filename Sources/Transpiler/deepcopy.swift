let deepcopy = """
function __ssdeepcopy(obj, refs = []) {
if (obj === null || typeof obj !== 'object') {
return obj;
}

if (typeof obj === 'function') {
const source = String(obj);
if (/^\\s*function\\s*\\S*\\([^\\)]*\\)\\s*{\\s*\\[native code\\]\\s*}/.test(source)) {
return obj;
} else {
return (new Function('return ' + source)());
}
}

if (toString.call(obj) === '[object Array]') {
const result = [];
for (let i = 0; i < obj.length; ++i) { result.push(__ssdeepcopy(obj[i])); }
return result;
}

for (let ref of refs) {
if (ref[0] === obj) { return ref[1]; }
}

const result = {};
refs.push([obj, result]);
for (const key in obj) {
if (Object.prototype.hasOwnProperty.call(obj, key)) { result[key] = __ssdeepcopy(obj[key], refs); }
}
return result;
}
"""
