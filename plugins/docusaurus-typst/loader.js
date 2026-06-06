const { execFileSync } = require('child_process');
const path = require('path');
const crypto = require('crypto');

// Mitgelieferte Schriften (z. B. Emoji-Subset), damit das Rendern unabhängig
// von den auf dem Build-Host installierten Systemschriften reproduzierbar ist.
const fontPath = path.resolve(__dirname, '..', '..', 'fonts');

module.exports = function typstLoader(source) {
  const resourcePath = this.resourcePath;
  const hash = crypto.createHash('md5').update(source).digest('hex').slice(0, 8);
  const baseName = path.basename(resourcePath, '.typ');
  const outputName = `${baseName}-${hash}.pdf`;

  // Loader bei Änderungen an den mitgelieferten Schriften neu ausführen.
  this.addContextDependency(fontPath);

  const pdfBuffer = execFileSync(
    'typst',
    ['compile', '--font-path', fontPath, resourcePath, '-'],
    { maxBuffer: 10 * 1024 * 1024 },
  );

  this.emitFile(outputName, pdfBuffer);

  return `module.exports = __webpack_public_path__ + ${JSON.stringify(outputName)};`;
};

module.exports.raw = false;
