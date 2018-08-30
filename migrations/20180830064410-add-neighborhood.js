let dbm
let type
let seed

/**
  * We receive the dbmigrate dependency from dbmigrate initially.
  * This enables us to not have to rely on NODE_PATH.
  */
exports.setup = function (options, seedLink) {
  dbm = options.dbmigrate
  type = dbm.dataType
  seed = seedLink
}

exports.up = function (db) {
  return db.createTable('neighborhood', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    external_id: { type: 'int', unique: true, notNull: true },
    short_name: { type: 'string', length: 1000, notNull: true },
    long__name: { type: 'string', length: 1000, notNull: true },
    sort_order: { type: 'int', unique: true, notNull: true }
  })
}

exports.down = function (db) {
  return db.dropTable('neighborhood')
}

exports._meta = {
  'version': 1
}
