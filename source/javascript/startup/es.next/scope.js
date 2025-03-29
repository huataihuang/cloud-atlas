this.scope = "lexical scope";

const scopeOf = {
    scope: "define scope",

    traditional: function () {
        return this.scope;
    },

    arrow: () => {
        return this.scope;
    },
};

console.log(scopeOf.traditional());
console.log(scopeOf.arrow());
