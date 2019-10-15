module.exports = {

  plugins: ["truffle-security"],

  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // Match any network id
      gas: 5000000
    },
    ganache: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*',
      gas: 8000000,
      gasPrice: 1000000000
    },
  },
  compilers: {
    solc: {
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200      // Default: 200
        }
      },
      version: '0.5.11'
    }
  },
  build: {
    // Copy ./app/index.html (right hand side) to ./build/index.html.
    'index.html': 'index.html',
    'app.js': [
      // Paths relative to "app" directory that should be
      // concatenated and processed during build.
      'javascripts/app.js'
    ],
    'app.css': [
      // Paths relative to "app" directory that should be
      // concatenated and processed during build.
      'stylesheets/app.css'
    ]
  }
};
