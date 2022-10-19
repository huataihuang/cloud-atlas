...
/* const HOST = process.env.HOST || 'localhost'; */
const PORT = process.env.PORT || '9000';
...
module.exports = merge(common('development'), {
  mode: 'development',
  devtool: 'eval-source-map',
  devServer: {
/*    host: HOST, */
    host: '0.0.0.0',
    port: PORT,
...
