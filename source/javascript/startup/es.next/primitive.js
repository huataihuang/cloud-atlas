const primitiveDataType = 1;
try {
    primitiveDataType = 2;
} catch (err) {
    console.log(err);
}

const nonPrimitiveDataType = [];
nonPrimitiveDataType.push(1);

console.log(nonPrimitiveDataType);
