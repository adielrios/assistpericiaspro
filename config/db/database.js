module.exports = {
  development: {
    client: 'sqlite3',
    connection: {
      filename: './data/assistpericias.sqlite'
    },
    useNullAsDefault: true,
    migrations: {
      directory: './src/migrations'
    },
    seeds: {
      directory: './src/seeds'
    }
  }
};
