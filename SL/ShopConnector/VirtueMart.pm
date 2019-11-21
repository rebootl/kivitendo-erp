package SL::ShopConnector::VirtueMart;

use strict;

use parent qw(SL::ShopConnector::Base);

use SL::JSON;
use LWP::UserAgent;
use Data::Dumper;

#use parent qw(SL::DB::Object);
#scalar => [ qw(config) ],
use Rose::Object::MakeMethods::Generic (
  'scalar --get_set_init' => [ qw(connector url) ],
);

sub get_order      { die 'get_order needs to be implemented' }

sub get_new_orders { die 'get_order needs to be implemented' }

sub update_part    { die 'update_part needs to be implemented' }

sub get_article    { die 'get_article needs to be implemented' }

sub get_categories { die 'get_order needs to be implemented' }

sub get_version    {
  my ($self) = @_;

  my $url = $self->url;
  my $data = $self->connector->get($url . "index.php?option=com_api&app=kivishop&resource=version&format=raw");
  my $type = $data->content_type;
  my $status_line = $data->status_line;

  if ($data->is_success && $type eq 'application/json') {
    # JSON string is in $data->content
    # ($data->content is a method returning the string)
    my $data_decoded = SL::JSON::decode_json($data->content);
    if ($data_decoded->{data}->{success}) {
      my %return = ( success => 1,
        data => { version => $data_decoded->{data}->{kivishop_plg_ver} },
        message => "Connection OK!"
      );
      return \%return;
    }
    # (for ref: returning the data directly kinda works as well)
    #return $data_decoded->{data};
  }
  my %return = ( success => 0,
    data    => { version => $url . ": " . $status_line, revision => $type },
    message => "Server not found or wrong data type",
  );
  return \%return;
}

sub init_url {
  my ($self) = @_;
  $self->url($self->config->protocol . "://" . $self->config->server . ":" .
    $self->config->port . $self->config->path);
}

sub init_connector {
  my ($self) = @_;
  my $ua = LWP::UserAgent->new;
  # using API Token w/ Bearer scheme for now
  $ua->default_header( 'Authorization' => "Bearer " . $self->config->password );
  #$ua->credentials(
  #    $self->config->server . ":" . $self->config->port,
  #    $self->config->realm,
  #    $self->config->login => $self->config->password
  #);
  return $ua;
}

1;

__END__

=encoding utf-8

=head1 NAME

  SL::ShopConnectorBase - this is the base class for shop connectors

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 AVAILABLE METHODS

=over 4

=item C<get_order>

=item C<get_new_orders>

=item C<update_part>

=item C<get_article>

=item C<get_categories>

=item C<get_version>

=back

=head1 SEE ALSO

L<SL::ShopConnector::ALL>

=head1 BUGS

None yet. :)

=head1 AUTHOR

G. Richardson <lt>information@kivitendo-premium.deE<gt>
W. Hahn E<lt>wh@futureworldsearch.netE<gt>

=cut
