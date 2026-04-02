const path = require('path');

module.exports = function typstPlugin() {
  return {
    name: 'docusaurus-typst',
    configureWebpack() {
      return {
        module: {
          rules: [
            {
              test: /\.typ$/,
              use: [
                {
                  loader: path.resolve(__dirname, 'loader.js'),
                },
              ],
            },
          ],
        },
      };
    },
  };
};
