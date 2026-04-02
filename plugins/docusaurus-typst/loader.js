const { execFileSync } = require('child_process');
const path = require('path');
const crypto = require('crypto');

module.exports = function typstLoader(source) {
  const resourcePath = this.resourcePath;
  const hash = crypto.createHash('md5').update(source).digest('hex').slice(0, 8);
  const baseName = path.basename(resourcePath, '.typ');
  const outputName = `${baseName}-${hash}.pdf`;

  const pdfBuffer = execFileSync('typst', ['compile', resourcePath, '-'], {
    maxBuffer: 10 * 1024 * 1024,
  });

  this.emitFile(outputName, pdfBuffer);

  return `module.exports = __webpack_public_path__ + ${JSON.stringify(outputName)};`;
};

module.exports.raw = false;
