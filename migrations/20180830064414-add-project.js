'use strict'

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
  return db.createTable('project', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    external_id: { type: 'int', unique: true, notNull: true },
    name: { type: 'string', length: 1000, notNull: true },
    start_date: 'timestamp',
    end_date: 'timestamp',
    published_date: 'timestamp',
    published: 'boolean',
    withdrawn: 'boolean',
    addresses: 'text[]',
    neighborhood_id: {
      type: 'int',
      foreignKey: {
        name: 'fk_project_neighborhood',
        table: 'neighborhood',
        rules: {
          onDelete: 'Restrict',
          onUpdate: 'Restrict'
        },
        mapping: { neighborhood_id: 'id' }
      }
    }
  })
}

exports.down = function (db) {
  return db.dropTable('project')
}

exports._meta = {
  'version': 1
}
