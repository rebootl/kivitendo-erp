# This file has been auto-generated. Do not modify it; it will be overwritten
# by rose_auto_create_model.pl automatically.
package SL::DB::RequirementSpec;

use strict;

use base qw(SL::DB::Object);

__PACKAGE__->meta->table('requirement_specs');

__PACKAGE__->meta->columns(
  customer_id             => { type => 'integer' },
  hourly_rate             => { type => 'numeric', default => '0', not_null => 1, precision => 2, scale => 8 },
  id                      => { type => 'serial', not_null => 1 },
  is_template             => { type => 'boolean', default => 'false' },
  itime                   => { type => 'timestamp', default => 'now()' },
  mtime                   => { type => 'timestamp' },
  net_sum                 => { type => 'numeric', default => '0', not_null => 1, precision => 2, scale => 12 },
  previous_fb_number      => { type => 'integer', not_null => 1 },
  previous_section_number => { type => 'integer', not_null => 1 },
  project_id              => { type => 'integer' },
  status_id               => { type => 'integer' },
  title                   => { type => 'text', not_null => 1 },
  type_id                 => { type => 'integer' },
  version_id              => { type => 'integer' },
  working_copy_id         => { type => 'integer' },
);

__PACKAGE__->meta->primary_key_columns([ 'id' ]);

__PACKAGE__->meta->allow_inline_column_values(1);

__PACKAGE__->meta->foreign_keys(
  customer => {
    class       => 'SL::DB::Customer',
    key_columns => { customer_id => 'id' },
  },

  project => {
    class       => 'SL::DB::Project',
    key_columns => { project_id => 'id' },
  },

  status => {
    class       => 'SL::DB::RequirementSpecStatus',
    key_columns => { status_id => 'id' },
  },

  type => {
    class       => 'SL::DB::RequirementSpecType',
    key_columns => { type_id => 'id' },
  },

  version => {
    class       => 'SL::DB::RequirementSpecVersion',
    key_columns => { version_id => 'id' },
  },

  working_copy => {
    class       => 'SL::DB::RequirementSpec',
    key_columns => { working_copy_id => 'id' },
  },
);

1;
;
