#=====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#############################################################################
# Veraendert 2005-01-05 - Marco Welter <mawe@linux-studio.de> - Neue Optik  #
#############################################################################
# SQL-Ledger, Accounting
# Copyright (c) 1998-2002
#
#  Author: Dieter Simader
#   Email: dsimader@sql-ledger.org
#     Web: http://www.sql-ledger.org
#
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#######################################################################
#
# common routines used in is, ir, oe
#
#######################################################################

use SL::IC;

require "$form->{path}/common.pl";

# any custom scripts for this one
if (-f "$form->{path}/custom_io.pl") {
  eval { require "$form->{path}/custom_io.pl"; };
}
if (-f "$form->{path}/$form->{login}_io.pl") {
  eval { require "$form->{path}/$form->{login}_io.pl"; };
}

1;

# end of main

# this is for our long dates
# $locale->text('January')
# $locale->text('February')
# $locale->text('March')
# $locale->text('April')
# $locale->text('May ')
# $locale->text('June')
# $locale->text('July')
# $locale->text('August')
# $locale->text('September')
# $locale->text('October')
# $locale->text('November')
# $locale->text('December')

# this is for our short month
# $locale->text('Jan')
# $locale->text('Feb')
# $locale->text('Mar')
# $locale->text('Apr')
# $locale->text('May')
# $locale->text('Jun')
# $locale->text('Jul')
# $locale->text('Aug')
# $locale->text('Sep')
# $locale->text('Oct')
# $locale->text('Nov')
# $locale->text('Dec')
use SL::IS;
use SL::PE;
use SL::AM;
use Data::Dumper;
########################################
# Eintrag fuer Version 2.2.0 geaendert #
# neue Optik im Rechnungsformular      #
########################################
sub display_row {
  $lxdebug->enter_sub();
  my $numrows = shift;
  if ($lizenzen && $form->{vc} eq "customer") {
    if ($form->{type} =~ /sales_order/) {
      @column_index = (runningnumber, partnumber, description, ship, qty);
    } elsif ($form->{type} =~ /sales_quotation/) {
      @column_index = (runningnumber, partnumber, description, qty);
    } else {
      @column_index = (runningnumber, partnumber, description, qty);
    }
  } else {
    if (   ($form->{type} =~ /purchase_order/)
        || ($form->{type} =~ /sales_order/)) {
      @column_index = (runningnumber, partnumber, description, ship, qty);
        } else {
      @column_index = (runningnumber, partnumber, description, qty);
    }
  }
############## ENDE Neueintrag ##################

  my $dimension_units = AM->retrieve_units(\%myconfig, $form, "dimension");
  my $service_units = AM->retrieve_units(\%myconfig, $form, "service");
  my $all_units = AM->retrieve_units(\%myconfig, $form);

  push @column_index, qw(unit);

  #for pricegroups column
  if (   $form->{type} =~ (/sales_quotation/)
      or (($form->{level} =~ /Sales/) and ($form->{type} =~ /invoice/))
      or (($form->{level} eq undef) and ($form->{type} =~ /invoice/))
      or ($form->{type} =~ /sales_order/)) {
    push @column_index, qw(sellprice_pg);
  }

  push @column_index, qw(sellprice);

  if ($form->{vc} eq 'customer') {
    push @column_index, qw(discount);
  }

  push @column_index, "linetotal";

  my $colspan = $#column_index + 1;

  $form->{invsubtotal} = 0;
  map { $form->{"${_}_base"} = 0 } (split / /, $form->{taxaccounts});

########################################
  # Eintrag fuer Version 2.2.0 geaendert #
  # neue Optik im Rechnungsformular      #
########################################
  $column_data{runningnumber} =
      qq|<th align=left nowrap width=5 class=listheading>|
    . $locale->text('No.')
    . qq|</th>|;
  $column_data{partnumber} =
      qq|<th align=left nowrap width=12 class=listheading>|
    . $locale->text('Number')
    . qq|</th>|;
  $column_data{description} =
      qq|<th align=left nowrap width=30 class=listheading>|
    . $locale->text('Part Description')
    . qq|</th>|;
  $column_data{ship} =
      qq|<th align=left nowrap width=5 class=listheading>|
    . $locale->text('Ship')
    . qq|</th>|;
  $column_data{qty} =
      qq|<th align=left nowrap width=5 class=listheading>|
    . $locale->text('Qty')
    . qq|</th>|;
  $column_data{unit} =
      qq|<th align=left nowrap width=5 class=listheading>|
    . $locale->text('Unit')
    . qq|</th>|;
  $column_data{license} =
      qq|<th align=left nowrap width=10 class=listheading>|
    . $locale->text('License')
    . qq|</th>|;
  $column_data{serialnr} =
      qq|<th align=left nowrap width=10 class=listheading>|
    . $locale->text('Serial No.')
    . qq|</th>|;
  $column_data{projectnr} =
      qq|<th align=left nowrap width=10 class=listheading>|
    . $locale->text('Project')
    . qq|</th>|;
  $column_data{sellprice} =
      qq|<th align=left nowrap width=15 class=listheading>|
    . $locale->text('Price')
    . qq|</th>|;
  $column_data{sellprice_pg} =
      qq|<th align=left nowrap width=15 class=listheading>|
    . $locale->text('Pricegroup')
    . qq|</th>|;
  $column_data{discount} =
      qq|<th align=left class=listheading>|
    . $locale->text('Discount')
    . qq|</th>|;
  $column_data{linetotal} =
      qq|<th align=left nowrap width=10 class=listheading>|
    . $locale->text('Extended')
    . qq|</th>|;
  $column_data{bin} =
      qq|<th align=left nowrap width=10 class=listheading>|
    . $locale->text('Bin')
    . qq|</th>|;
############## ENDE Neueintrag ##################

  print qq|
  <tr>
    <td>
      <table width=100%>
	<tr class=listheading>|;

  map { print "\n$column_data{$_}" } @column_index;

  print qq|
        </tr>
|;

  $runningnumber = $locale->text('No.');
  $deliverydate  = $locale->text('Delivery Date');
  $serialnumber  = $locale->text('Serial No.');
  $projectnumber = $locale->text('Project');
  $partsgroup    = $locale->text('Group');
  $reqdate       = $locale->text('Reqdate');

  $delvar = 'deliverydate';

  if ($form->{type} =~ /_order$/ || $form->{type} =~ /_quotation$/) {
    $deliverydate = $locale->text('Required by');
    $delvar       = 'reqdate';
  }

  for $i (1 .. $numrows) {

    # undo formatting
    map {
      $form->{"${_}_$i"} =
        $form->parse_amount(\%myconfig, $form->{"${_}_$i"})
    } qw(qty ship discount sellprice price_new price_old) unless ($form->{simple_save});

    if (!$form->{"unit_old_$i"}) {
      # Neue Ware aus der Datenbank. In diesem Fall ist unit_$i die
      # Einheit, wie sie in den Stammdaten hinterlegt wurde.
      # Es sollte also angenommen werden, dass diese ausgewaehlt war.
      $form->{"unit_old_$i"} = $form->{"unit_$i"};
    }



    # Die zuletzt ausgewaehlte mit der aktuell ausgewaehlten Einheit
    # vergleichen und bei Unterschied den Preis entsprechend umrechnen.
    $form->{"selected_unit_$i"} = $form->{"unit_$i"} unless ($form->{"selected_unit_$i"});

    my $check_units = $form->{"inventory_accno_$i"} ? $dimension_units : $service_units;
    if (!$check_units->{$form->{"selected_unit_$i"}} ||
        ($check_units->{$form->{"selected_unit_$i"}}->{"base_unit"} ne
         $all_units->{$form->{"unit_old_$i"}}->{"base_unit"})) {
      # Die ausgewaehlte Einheit ist fuer diesen Artikel nicht gueltig
      # (z.B. Dimensionseinheit war ausgewaehlt, es handelt sich aber
      # um eine Dienstleistung). Dann keinerlei Umrechnung vornehmen.
      $form->{"unit_old_$i"} = $form->{"selected_unit_$i"} = $form->{"unit_$i"};
    }
    if ((!$form->{"prices_$i"}) || ($form->{"new_pricegroup_$i"} == $form->{"old_pricegroup_$i"})) {
      if ($form->{"unit_old_$i"} ne $form->{"selected_unit_$i"}) {
        my $basefactor = 1;
        if (defined($all_units->{$form->{"unit_old_$i"}}->{"factor"}) &&
            $all_units->{$form->{"unit_old_$i"}}->{"factor"}) {
          $basefactor = $all_units->{$form->{"selected_unit_$i"}}->{"factor"} /
            $all_units->{$form->{"unit_old_$i"}}->{"factor"};
        }
        $form->{"sellprice_$i"} *= $basefactor;
        $form->{"unit_old_$i"} = $form->{"selected_unit_$i"};
      }
    }
    ($dec) = ($form->{"sellprice_$i"} =~ /\.(\d+)/);
    $dec           = length $dec;
    $decimalplaces = ($dec > 2) ? $dec : 2;

    $discount =
      $form->round_amount(
                        $form->{"sellprice_$i"} * $form->{"discount_$i"} / 100,
                        $decimalplaces);

    $linetotal =
      $form->round_amount($form->{"sellprice_$i"} - $discount, $decimalplaces);
    $linetotal = $form->round_amount($linetotal * $form->{"qty_$i"}, 2);

    # convert " to &quot;
    map { $form->{"${_}_$i"} =~ s/\"/&quot;/g }
      qw(partnumber description unit unit_old);

########################################
    # Eintrag fuer Version 2.2.0 geaendert #
    # neue Optik im Rechnungsformular      #
########################################
    $column_data{runningnumber} =
      qq|<td><input name="runningnumber_$i" size=5 value=$i></td>|;    # HuT
############## ENDE Neueintrag ##################

    $column_data{partnumber} =
      qq|<td><input name="partnumber_$i" size=12 value="$form->{"partnumber_$i"}"></td>|;

    if (($rows = $form->numtextrows($form->{"description_$i"}, 30, 6)) > 1) {
      $column_data{description} =
        qq|<td><textarea name="description_$i" rows=$rows cols=30 wrap=soft>$form->{"description_$i"}</textarea><button type="button" onclick="set_longdescription_window('longdescription_$i')">| . $locale->text('L') . qq|</button></td>|;
    } else {
      $column_data{description} =
        qq|<td><input name="description_$i" size=30 value="$form->{"description_$i"}"><button type="button" onclick="set_longdescription_window('longdescription_$i')">| . $locale->text('L') . qq|</button></td>|;
    }

    (my $qty_dec) = ($form->{"qty_$i"} =~ /\.(\d+)/);
    $qty_dec = length $qty_dec;

    $column_data{qty} =
        qq|<td align=right><input name="qty_$i" size=5 value=|
      . $form->format_amount(\%myconfig, $form->{"qty_$i"}, $qty_dec) .qq|>|;
    if ($form->{"formel_$i"}) {
    $column_data{qty} .= qq|<button type="button" onclick="calculate_qty_selection_window('qty_$i','alu_$i', 'formel_$i', $i)">| . $locale->text('*/') . qq|</button>
          <input type=hidden name="formel_$i" value="$form->{"formel_$i"}"><input type=hidden name="alu_$i" value="$form->{"alu_$i"}"></td>|;
    }
    $column_data{ship} =
        qq|<td align=right><input name="ship_$i" size=5 value=|
      . $form->format_amount(\%myconfig, $form->{"ship_$i"})
      . qq|></td>|;

    my $is_part = $form->{"inventory_accno_$i"};
    my $is_assigned = $form->{"id_$i"};
    my $this_unit = $form->{"unit_$i"};
    if ($form->{"selected_unit_$i"} && $this_unit &&
        $all_units->{$form->{"selected_unit_$i"}} && $all_units->{$this_unit} &&
        ($all_units->{$form->{"selected_unit_$i"}}->{"base_unit"} eq $all_units->{$this_unit}->{"base_unit"})) {
      $this_unit = $form->{"selected_unit_$i"};
    } elsif (!$is_assigned ||
             ($is_part && !$this_unit && ($all_units->{$this_unit} && ($all_units->{$this_unit}->{"base_unit"} eq $all_units->{"kg"}->{"base_unit"})))) {
      $this_unit = "kg";
    }

    $column_data{"unit"} = "<td>" .
      ($qty_readonly ? "&nbsp;" :
       AM->unit_select_html($is_part ? $dimension_units :
                            $is_assigned ? $service_units : $all_units,
                            "unit_$i", $this_unit,
                            $is_assigned ? $form->{"unit_$i"} : undef))
      . "</td>";

    # build in drop down list for pricesgroups
    if ($form->{"prices_$i"}) {
      if  ($form->{"new_pricegroup_$i"} != $form->{"old_pricegroup_$i"}) {
        $price_tmp = $form->format_amount(\%myconfig, $form->{"price_new_$i"}, $decimalplaces);
      } else {
        $price_tmp = $form->format_amount(\%myconfig, $form->{"sellprice_$i"}, $decimalplaces);
      }

      $column_data{sellprice_pg} =
        qq|<td align=right><select name="sellprice_pg_$i">$form->{"prices_$i"}</select></td>|;
      $column_data{sellprice} =
        qq|<td><input name="sellprice_$i" size=10 value=$price_tmp></td>|;
    } else {

      # for last row and report
      # set pricegroup drop down list from report menu
      if ($form->{"sellprice_$i"} != 0) {
        $prices =
          qq|<option value="$form->{"sellprice_$i"}--$form->{"pricegroup_id_$i"}" selected>$form->{"pricegroup_$i"}</option>\n|;

        $form->{"pricegroup_old_$i"} = $form->{"pricegroup_id_$i"};

        $column_data{sellprice_pg} =
          qq|<td align=right><select name="sellprice_pg_$i">$prices</select></td>|;

      } else {

        # for last row
        $column_data{sellprice_pg} = qq|<td align=right>&nbsp;</td>|;
      }

      $column_data{sellprice} =
        qq|<td><input name="sellprice_$i" size=10 value=|
        . $form->format_amount(\%myconfig, $form->{"sellprice_$i"},
                               $decimalplaces)
        . qq|></td>|;
    }
    $column_data{discount} =
        qq|<td align=right><input name="discount_$i" size=3 value=|
      . $form->format_amount(\%myconfig, $form->{"discount_$i"})
      . qq|></td>|;
    $column_data{linetotal} =
        qq|<td align=right>|
      . $form->format_amount(\%myconfig, $linetotal, 2)
      . qq|</td>|;
    $column_data{bin} = qq|<td>$form->{"bin_$i"}</td>|;

########################################
    # Eintrag fuer Version 2.2.0 geaendert #
    # neue Optik im Rechnungsformular      #
########################################
    #     if ($lizenzen &&  $form->{type} eq "invoice" &&  $form->{vc} eq "customer") {
    #     $column_data{license} = qq|<td><select name="licensenumber_$i">$form->{"lizenzen_$i"}></select></td>|;
    #     }
    #
    #     if ($form->{type} !~ /_quotation/) {
    #     $column_data{serialnr} = qq|<td><input name="serialnumber_$i" size=10 value="$form->{"serialnumber_$i"}"></td>|;
    #     }
    #
    #     $column_data{projectnr} = qq|<td><input name="projectnumber_$i" size=10 value="$form->{"projectnumber_$i"}"></td>|;
############## ENDE Neueintrag ##################
    my $j = $i % 2;
    print qq|

        <tr valign=top class=listrow$j>|;

    map { print "\n$column_data{$_}" } @column_index;

    print qq|
        </tr>

<input type=hidden name="orderitems_id_$i" value=$form->{"orderitems_id_$i"}>
<input type=hidden name="bo_$i" value=$form->{"bo_$i"}>

<input type=hidden name="pricegroup_old_$i" value=$form->{"pricegroup_old_$i"}>
<input type=hidden name="price_old_$i" value=$form->{"price_old_$i"}>
<input type=hidden name="unit_old_$i" value="$form->{"selected_unit_$i"}">
<input type=hidden name="price_new_$i" value=|
      . $form->format_amount(\%myconfig, $form->{"price_new_$i"}) . qq|>

<input type=hidden name="id_$i" value=$form->{"id_$i"}>
<input type=hidden name="inventory_accno_$i" value=$form->{"inventory_accno_$i"}>
<input type=hidden name="bin_$i" value="$form->{"bin_$i"}">
<input type=hidden name="partsgroup_$i" value="$form->{"partsgroup_$i"}">
<input type=hidden name="partnotes_$i" value="$form->{"partnotes_$i"}">
<input type=hidden name="income_accno_$i" value=$form->{"income_accno_$i"}>
<input type=hidden name="expense_accno_$i" value=$form->{"expense_accno_$i"}>
<input type=hidden name="listprice_$i" value="$form->{"listprice_$i"}">
<input type=hidden name="assembly_$i" value="$form->{"assembly_$i"}">
<input type=hidden name="taxaccounts_$i" value="$form->{"taxaccounts_$i"}">
<input type=hidden name="ordnumber_$i" value="$form->{"ordnumber_$i"}">
<input type=hidden name="transdate_$i" value="$form->{"transdate_$i"}">
<input type=hidden name="cusordnumber_$i" value="$form->{"cusordnumber_$i"}">
<input type=hidden name="longdescription_$i" value="$form->{"longdescription_$i"}">
<input type=hidden name="basefactor_$i" value="$form->{"basefactor_$i"}">

|;

########################################
    # Eintrag fuer Version 2.2.0 geaendert #
    # neue Optik im Rechnungsformular      #
########################################
    # print second row
    print qq|
        <tr  class=listrow$j>
	  <td colspan=$colspan>
|;
    if ($lizenzen && $form->{type} eq "invoice" && $form->{vc} eq "customer") {
      my $selected = $form->{"licensenumber_$i"};
      my $lizenzen_quoted;
      $form->{"lizenzen_$i"} =~ s/ selected//g;
      $form->{"lizenzen_$i"} =~
        s/value="${selected}"\>/value="${selected}" selected\>/;
      $lizenzen_quoted = $form->{"lizenzen_$i"};
      $lizenzen_quoted =~ s/\"/&quot;/g;
      print qq|
	<b>Lizenz\#</b>&nbsp;<select name="licensenumber_$i" size=1>
	$form->{"lizenzen_$i"}
        </select>
	<input type=hidden name="lizenzen_$i" value="${lizenzen_quoted}">
|;
    }
    if ($form->{type} !~ /_quotation/) {
      print qq|
          <b>$serialnumber</b>&nbsp;<input name="serialnumber_$i" size=15 value="$form->{"serialnumber_$i"}">|;
    }

    print qq|
          <b>$projectnumber</b>&nbsp;<input name="projectnumber_$i" size=10 value="$form->{"projectnumber_$i"}">
		  <input type=hidden name="oldprojectnumber_$i" value="$form->{"oldprojectnumber_$i"}">
		  <input type=hidden name="project_id_$i" value="$form->{"project_id_$i"}">
|;
    if ($form->{type} eq 'invoice' or $form->{type} =~ /order/) {
      my $reqdate_term =
        ($form->{type} eq 'invoice')
        ? 'deliverydate'
        : 'reqdate';    # invoice uses a different term for the same thing.
      print qq|
        <b>${$reqdate_term}</b>&nbsp;<input name="${reqdate_term}_$i" size=11 value="$form->{"${reqdate_term}_$i"}">
|;
    }
    my $subtotalchecked = ($form->{"subtotal_$i"}) ? "checked" : "";
    print qq|
          <b>|.$locale->text('Subtotal').qq|</b>&nbsp;<input type="checkbox" name="subtotal_$i" value="1" "$subtotalchecked">
	  </td>
	</tr>

|;

############## ENDE Neueintrag ##################

    map { $form->{"${_}_base"} += $linetotal }
      (split / /, $form->{"taxaccounts_$i"});

    $form->{invsubtotal} += $linetotal;
  }

  print qq|
      </table>
    </td>
  </tr>
|;

  $lxdebug->leave_sub();
}

##################################################
# build html-code for pricegroups in variable $form->{prices_$j}

sub set_pricegroup {
  $lxdebug->enter_sub();
  my $rowcount = shift;
  for $j (1 .. $rowcount) {
    my $pricegroup_old = $form->{"pricegroup_old_$i"};
    if ($form->{PRICES}{$j}) {
      $len    = 0;
      $prices = '<option value="--">' . $locale->text("none (pricegroup)") . '</option>';
      $price  = 0;
      foreach $item (@{ $form->{PRICES}{$j} }) {

        #$price = $form->round_amount($myconfig,  $item->{price}, 5);
        #$price = $form->format_amount($myconfig, $item->{price}, 2);
        $price         = $item->{price};
        $pricegroup_id = $item->{pricegroup_id};
        $pricegroup    = $item->{pricegroup};

        # build drop down list for pricegroups
        $prices .=
          qq|<option value="$price--$pricegroup_id"$item->{selected}>$pricegroup</option>\n|;

        $len += 1;

        #        map {
        #               $form->{"${_}_$j"} =
        #               $form->format_amount(\%myconfig, $form->{"${_}_$j"})
        #              } qw(sellprice price_new price_old);

        # set new selectedpricegroup_id and prices for "Preis"
        if ($item->{selected} && ($pricegroup_id != 0)) {
          $form->{"pricegroup_old_$j"} = $pricegroup_id;
          $form->{"price_new_$j"}      = $price;
          $form->{"sellprice_$j"}      = $price;
        }
        if ($pricegroup_id == 0) {
          $form->{"price_new_$j"} = $form->{"sellprice_$j"};
        }
      }
      $form->{"prices_$j"} = $prices;
    }
  }
  $lxdebug->leave_sub();
}

sub select_item {
  $lxdebug->enter_sub();
  @column_index = qw(ndx partnumber description onhand sellprice);

  $column_data{ndx}        = qq|<th>&nbsp;</th>|;
  $column_data{partnumber} =
    qq|<th class=listheading>| . $locale->text('Number') . qq|</th>|;
  $column_data{description} =
    qq|<th class=listheading>| . $locale->text('Part Description') . qq|</th>|;
  $column_data{sellprice} =
    qq|<th class=listheading>| . $locale->text('Price') . qq|</th>|;
  $column_data{onhand} =
    qq|<th class=listheading>| . $locale->text('Qty') . qq|</th>|;

  # list items with radio button on a form
  $form->header;

  $title   = $locale->text('Select from one of the items below');
  $colspan = $#column_index + 1;

  print qq|
<body>

<form method=post action=$form->{script}>

<table width=100%>
  <tr>
    <th class=listtop colspan=$colspan>$title</th>
  </tr>
  <tr height="5"></tr>
  <tr class=listheading>|;

  map { print "\n$column_data{$_}" } @column_index;

  print qq|</tr>|;

  my $i = 0;
  foreach $ref (@{ $form->{item_list} }) {
    $checked = ($i++) ? "" : "checked";

    if ($lizenzen) {
      if ($ref->{inventory_accno} > 0) {
        $ref->{"lizenzen"} = qq|<option></option>|;
        foreach $item (@{ $form->{LIZENZEN}{ $ref->{"id"} } }) {
          $ref->{"lizenzen"} .=
            qq|<option value=\"$item->{"id"}\">$item->{"licensenumber"}</option>|;
        }
        $ref->{"lizenzen"} .= qq|<option value=-1>Neue Lizenz</option>|;
        $ref->{"lizenzen"} =~ s/\"/&quot;/g;
      }
    }

    map { $ref->{$_} =~ s/\"/&quot;/g } qw(partnumber description unit);

    #sk tradediscount
    $ref->{sellprice} =
      $form->round_amount($ref->{sellprice} * (1 - $form->{tradediscount}), 2);
    $column_data{ndx} =
      qq|<td><input name=ndx class=radio type=radio value=$i $checked></td>|;
    $column_data{partnumber} =
      qq|<td><input name="new_partnumber_$i" type=hidden value="$ref->{partnumber}">$ref->{partnumber}</td>|;
    $column_data{description} =
      qq|<td><input name="new_description_$i" type=hidden value="$ref->{description}">$ref->{description}</td>|;
    $column_data{sellprice} =
      qq|<td align=right><input name="new_sellprice_$i" type=hidden value=$ref->{sellprice}>|
      . $form->format_amount(\%myconfig, $ref->{sellprice}, 2, "&nbsp;")
      . qq|</td>|;
    $column_data{onhand} =
      qq|<td align=right><input name="new_onhand_$i" type=hidden value=$ref->{onhand}>|
      . $form->format_amount(\%myconfig, $ref->{onhand}, '', "&nbsp;")
      . qq|</td>|;

    $j++;
    $j %= 2;
    print qq|
<tr class=listrow$j>|;

    map { print "\n$column_data{$_}" } @column_index;

    print qq|
</tr>

<input name="new_bin_$i" type=hidden value="$ref->{bin}">
<input name="new_listprice_$i" type=hidden value=$ref->{listprice}>
<input name="new_inventory_accno_$i" type=hidden value=$ref->{inventory_accno}>
<input name="new_income_accno_$i" type=hidden value=$ref->{income_accno}>
<input name="new_expense_accno_$i" type=hidden value=$ref->{expense_accno}>
<input name="new_unit_$i" type=hidden value="$ref->{unit}">
<input name="new_weight_$i" type=hidden value="$ref->{weight}">
<input name="new_assembly_$i" type=hidden value="$ref->{assembly}">
<input name="new_taxaccounts_$i" type=hidden value="$ref->{taxaccounts}">
<input name="new_partsgroup_$i" type=hidden value="$ref->{partsgroup}">
<input name="new_formel_$i" type=hidden value="$ref->{formel}">
<input name="new_longdescription_$i" type=hidden value="$ref->{longdescription}">
<input name="new_not_discountable_$i" type=hidden value="$ref->{not_discountable}">
<input name="new_part_payment_id_$i" type=hidden value="$ref->{part_payment_id}">

<input name="new_id_$i" type=hidden value=$ref->{id}>

|;
    if ($lizenzen) {
      print qq|
<input name="new_lizenzen_$i" type=hidden value="$ref->{lizenzen}">
|;
    }

  }

  print qq|
<tr><td colspan=8><hr size=3 noshade></td></tr>
</table>

<input name=lastndx type=hidden value=$i>

|;

  # delete action variable
  map { delete $form->{$_} } qw(action item_list header);

  # save all other form variables
  foreach $key (keys %${form}) {
    $form->{$key} =~ s/\"/&quot;/g;
    print qq|<input name=$key type=hidden value="$form->{$key}">\n|;
  }

  print qq|
<input type=hidden name=nextsub value=item_selected>

<br>
<input class=submit type=submit name=action value="|
    . $locale->text('Continue') . qq|">
</form>

</body>
</html>
|;

  $lxdebug->leave_sub();
}

sub item_selected {
  $lxdebug->enter_sub();

  # replace the last row with the checked row
  $i = $form->{rowcount};
  $i = $form->{assembly_rows} if ($form->{item} eq 'assembly');

  # index for new item
  $j = $form->{ndx};

  #sk
  #($form->{"sellprice_$i"},$form->{"$pricegroup_old_$i"}) = split /--/, $form->{"sellprice_$i"};
  #$form->{"sellprice_$i"} = $form->{"sellprice_$i"};

  # if there was a price entered, override it
  $sellprice = $form->parse_amount(\%myconfig, $form->{"sellprice_$i"});

  map { $form->{"${_}_$i"} = $form->{"new_${_}_$j"} }
    qw(id partnumber description sellprice listprice inventory_accno income_accno expense_accno bin unit weight assembly taxaccounts partsgroup formel longdescription not_discountable);
  if ($form->{"part_payment_id_$i"} ne "") {
    $form->{payment_id} = $form->{"part_payment_id_$i"};
  }

  if ($lizenzen) {
    map { $form->{"${_}_$i"} = $form->{"new_${_}_$j"} } qw(lizenzen);
  }

  ($dec) = ($form->{"sellprice_$i"} =~ /\.(\d+)/);
  $dec           = length $dec;
  $decimalplaces = ($dec > 2) ? $dec : 2;

  if ($sellprice) {
    $form->{"sellprice_$i"} = $sellprice;
  } else {

    # if there is an exchange rate adjust sellprice
    if (($form->{exchangerate} * 1) != 0) {
      $form->{"sellprice_$i"} /= $form->{exchangerate};
      $form->{"sellprice_$i"} =
        $form->round_amount($form->{"sellprice_$i"}, $decimalplaces);
    }
  }

  map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) }
    qw(sellprice listprice weight);

  $form->{sellprice} += ($form->{"sellprice_$i"} * $form->{"qty_$i"});
  $form->{weight}    += ($form->{"weight_$i"} * $form->{"qty_$i"});
  
  if ($form->{"not_discountable_$i"}) {
    $form->{"discount_$i"} = 0;
  }

  $amount =
    $form->{"sellprice_$i"} * (1 - $form->{"discount_$i"} / 100) *
    $form->{"qty_$i"};
  map { $form->{"${_}_base"} += $amount }
    (split / /, $form->{"taxaccounts_$i"});
  map { $amount += ($form->{"${_}_base"} * $form->{"${_}_rate"}) } split / /,
    $form->{"taxaccounts_$i"}
    if !$form->{taxincluded};

  $form->{creditremaining} -= $amount;

  $form->{"runningnumber_$i"} = $i;

  # delete all the new_ variables
  for $i (1 .. $form->{lastndx}) {
    map { delete $form->{"new_${_}_$i"} }
      qw(partnumber description sellprice bin listprice inventory_accno income_accno expense_accno unit assembly taxaccounts id);
  }

  map { delete $form->{$_} } qw(ndx lastndx nextsub);

  # format amounts
  map {
    $form->{"${_}_$i"} =
      $form->format_amount(\%myconfig, $form->{"${_}_$i"}, $decimalplaces)
  } qw(sellprice listprice) if $form->{item} ne 'assembly';

  # get pricegroups for parts
  IS->get_pricegroups_for_parts(\%myconfig, \%$form);

  # build up html code for prices_$i
  set_pricegroup($form->{rowcount});

  &display_form;

  $lxdebug->leave_sub();
}

sub new_item {
  $lxdebug->enter_sub();

  # change callback
  $form->{old_callback} = $form->escape($form->{callback}, 1);
  $form->{callback} = $form->escape("$form->{script}?action=display_form", 1);

  # delete action
  delete $form->{action};

  # save all other form variables in a previousform variable
  foreach $key (keys %$form) {

    # escape ampersands
    $form->{$key} =~ s/&/%26/g;
    $previousform .= qq|$key=$form->{$key}&|;
  }
  chop $previousform;
  $previousform = $form->escape($previousform, 1);

  $i = $form->{rowcount};
  map { $form->{"${_}_$i"} =~ s/\"/&quot;/g } qw(partnumber description);

  $form->header;

  print qq|
<body>

<h4 class=error>| . $locale->text('Item not on file!') . qq|

<p>
| . $locale->text('What type of item is this?') . qq|</h4>

<form method=post action=ic.pl>

<p>

  <input class=radio type=radio name=item value=part checked>&nbsp;|
    . $locale->text('Part') . qq|<br>
  <input class=radio type=radio name=item value=service>&nbsp;|
    . $locale->text('Service')

    . qq|
<input type=hidden name=previousform value="$previousform">
<input type=hidden name=partnumber value="$form->{"partnumber_$i"}">
<input type=hidden name=description value="$form->{"description_$i"}">
<input type=hidden name=rowcount value=$form->{rowcount}>
<input type=hidden name=taxaccount2 value=$form->{taxaccounts}>
<input type=hidden name=vc value=$form->{vc}>

<input type=hidden name=path value=$form->{path}>
<input type=hidden name=login value=$form->{login}>
<input type=hidden name=password value=$form->{password}>

<input type=hidden name=nextsub value=add>

<p>
<input class=submit type=submit name=action value="|
    . $locale->text('Continue') . qq|">
</form>

</body>
</html>
|;

  $lxdebug->leave_sub();
}

sub display_form {
  $lxdebug->enter_sub();

  relink_accounts();

  $form->language_payment(\%myconfig);

  # if we have a display_form
  if ($form->{display_form}) {
    &{"$form->{display_form}"};
    exit;
  }

  #   if (   $form->{print_and_post}
  #       && $form->{second_run}
  #       && ($form->{action} eq "display_form")) {
  #     for (keys %$form) { $old_form->{$_} = $form->{$_} }
  #     $old_form->{rowcount}++;
  #
  #     #$form->{rowcount}--;
  #     #$form->{rowcount}--;
  #
  #     $form->{print_and_post} = 0;
  #
  #     &print_form($old_form);
  #     exit;
  #   }
  #
  #   $form->{action}   = "";
  #   $form->{resubmit} = 0;
  #
  #   if ($form->{print_and_post} && !$form->{second_run}) {
  #     $form->{second_run} = 1;
  #     $form->{action}     = "display_form";
  #     $form->{rowcount}--;
  #     my $rowcount = $form->{rowcount};
  #
  #     # get pricegroups for parts
  #     IS->get_pricegroups_for_parts(\%myconfig, \%$form);
  #
  #     # build up html code for prices_$i
  #     set_pricegroup($rowcount);
  #
  #     $form->{resubmit} = 1;
  #
  #   }
  &form_header;

  $numrows    = ++$form->{rowcount};
  $subroutine = "display_row";

  if ($form->{item} eq 'part') {

    #set preisgruppenanzahl
    $numrows    = $form->{price_rows};
    $subroutine = "price_row";

    &{$subroutine}($numrows);

    $numrows    = ++$form->{makemodel_rows};
    $subroutine = "makemodel_row";
  }
  if ($form->{item} eq 'assembly') {
    $numrows    = $form->{price_rows};
    $subroutine = "price_row";

    &{$subroutine}($numrows);

    $numrows    = ++$form->{makemodel_rows};
    $subroutine = "makemodel_row";

    # create makemodel rows
    &{$subroutine}($numrows);

    $numrows    = ++$form->{assembly_rows};
    $subroutine = "assembly_row";
  }
  if ($form->{item} eq 'service') {
    $numrows    = $form->{price_rows};
    $subroutine = "price_row";

    &{$subroutine}($numrows);

    $numrows = 0;
  }

  # create rows
  &{$subroutine}($numrows) if $numrows;

  &form_footer;

  $lxdebug->leave_sub();
}

sub check_form {
  $lxdebug->enter_sub();
  my @a     = ();
  my $count = 0;
  my @flds  = (
    qw(id partnumber description qty ship sellprice unit discount inventory_accno income_accno expense_accno listprice taxaccounts bin assembly weight projectnumber project_id oldprojectnumber runningnumber serialnumber partsgroup payment_id not_discountable shop ve gv buchungsgruppen_id language_values sellprice_pg pricegroup_old price_old price_new unit_old ordnumber transdate longdescription basefactor)
  );


  # remove any makes or model rows
  if ($form->{item} eq 'part') {
    map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) }
      qw(listprice sellprice lastcost weight rop);

    @flds = (make, model);
    for my $i (1 .. ($form->{makemodel_rows})) {
      if (($form->{"make_$i"} ne "") || ($form->{"model_$i"} ne "")) {
        push @a, {};
        my $j = $#a;

        map { $a[$j]->{$_} = $form->{"${_}_$i"} } @flds;
        $count++;
      }
    }

    $form->redo_rows(\@flds, \@a, $count, $form->{makemodel_rows});
    $form->{makemodel_rows} = $count;

  } elsif ($form->{item} eq 'assembly') {

    $form->{sellprice} = 0;
    $form->{weight}    = 0;
    map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) }
      qw(listprice rop stock);

    @flds =
      qw(id qty unit bom partnumber description sellprice weight runningnumber partsgroup);

    for my $i (1 .. ($form->{assembly_rows} - 1)) {
      if ($form->{"qty_$i"}) {
        push @a, {};
        my $j = $#a;

        $form->{"qty_$i"} = $form->parse_amount(\%myconfig, $form->{"qty_$i"});

        map { $a[$j]->{$_} = $form->{"${_}_$i"} } @flds;

        #($form->{"sellprice_$i"},$form->{"$pricegroup_old_$i"}) = split /--/, $form->{"sellprice_$i"};

        $form->{sellprice} += ($form->{"qty_$i"} * $form->{"sellprice_$i"});
        $form->{weight}    += ($form->{"qty_$i"} * $form->{"weight_$i"});
        $count++;
      }
    }

    $form->{sellprice} = $form->round_amount($form->{sellprice}, 2);

    $form->redo_rows(\@flds, \@a, $count, $form->{assembly_rows});
    $form->{assembly_rows} = $count;

    $count = 0;
    @flds  = qw(make model);
    @a     = ();

    for my $i (1 .. ($form->{makemodel_rows})) {
      if (($form->{"make_$i"} ne "") || ($form->{"model_$i"} ne "")) {
        push @a, {};
        my $j = $#a;

        map { $a[$j]->{$_} = $form->{"${_}_$i"} } @flds;
        $count++;
      }
    }

    $form->redo_rows(\@flds, \@a, $count, $form->{makemodel_rows});
    $form->{makemodel_rows} = $count;

  } else {

    # this section applies to invoices and orders
    # remove any empty numbers
    if ($form->{rowcount}) {
      for my $i (1 .. $form->{rowcount} - 1) {
        if ($form->{"partnumber_$i"}) {
          push @a, {};
          my $j = $#a;

          map { $a[$j]->{$_} = $form->{"${_}_$i"} } @flds;
          $count++;
          if ($lizenzen) {
            if ($form->{"licensenumber_$i"} == -1) {
              &new_license($i);
              exit;
            }
          }
        }
      }

      $form->redo_rows(\@flds, \@a, $count, $form->{rowcount});
      $form->{rowcount} = $count;

      $form->{creditremaining} -= &invoicetotal;

    }
  }

  #sk
  # if pricegroups
  if (   $form->{type} =~ (/sales_quotation/)
      or (($form->{level} =~ /Sales/) and ($form->{type} =~ /invoice/))
      or (($form->{level} eq undef) and ($form->{type} =~ /invoice/))
      or ($form->{type} =~ /sales_order/)) {

    # get pricegroups for parts
    IS->get_pricegroups_for_parts(\%myconfig, \%$form);

    # build up html code for prices_$i
    set_pricegroup($form->{rowcount});

  }

  &display_form;

  $lxdebug->leave_sub();
}

sub invoicetotal {
  $lxdebug->enter_sub();

  $form->{oldinvtotal} = 0;

  # add all parts and deduct paid
  map { $form->{"${_}_base"} = 0 } split / /, $form->{taxaccounts};

  my ($amount, $sellprice, $discount, $qty);

  for my $i (1 .. $form->{rowcount}) {
    $sellprice = $form->parse_amount(\%myconfig, $form->{"sellprice_$i"});
    $discount  = $form->parse_amount(\%myconfig, $form->{"discount_$i"});
    $qty       = $form->parse_amount(\%myconfig, $form->{"qty_$i"});

    #($form->{"sellprice_$i"}, $form->{"$pricegroup_old_$i"}) = split /--/, $form->{"sellprice_$i"};

    $amount = $sellprice * (1 - $discount / 100) * $qty;
    map { $form->{"${_}_base"} += $amount }
      (split / /, $form->{"taxaccounts_$i"});
    $form->{oldinvtotal} += $amount;
  }

  map { $form->{oldinvtotal} += ($form->{"${_}_base"} * $form->{"${_}_rate"}) }
    split / /, $form->{taxaccounts}
    if !$form->{taxincluded};

  $form->{oldtotalpaid} = 0;
  for $i (1 .. $form->{paidaccounts}) {
    $form->{oldtotalpaid} += $form->{"paid_$i"};
  }

  $lxdebug->leave_sub();

  # return total
  return ($form->{oldinvtotal} - $form->{oldtotalpaid});
}

sub validate_items {
  $lxdebug->enter_sub();

  # check if items are valid
  if ($form->{rowcount} == 1) {
    &update;
    exit;
  }

  for $i (1 .. $form->{rowcount} - 1) {
    $form->isblank("partnumber_$i",
                   $locale->text('Number missing in Row') . " $i");
  }

  $lxdebug->leave_sub();
}

sub order {
  $lxdebug->enter_sub();
  if ($form->{second_run}) {
    $form->{print_and_post} = 0;
  }
  $form->{ordnumber} = $form->{invnumber};

  map { delete $form->{$_} } qw(id printed emailed queued);
  if ($form->{script} eq 'ir.pl' || $form->{type} eq 'request_quotation') {
    $form->{title} = $locale->text('Add Purchase Order');
    $form->{vc}    = 'vendor';
    $form->{type}  = 'purchase_order';
    $buysell       = 'sell';
  }
  if ($form->{script} eq 'is.pl' || $form->{type} eq 'sales_quotation') {
    $form->{title} = $locale->text('Add Sales Order');
    $form->{vc}    = 'customer';
    $form->{type}  = 'sales_order';
    $buysell       = 'buy';
  }
  $form->{script} = 'oe.pl';

  $form->{shipto} = 1;

  $form->{rowcount}--;

  $form->{cp_id} *= 1;

  require "$form->{path}/$form->{script}";

  map { $form->{"select$_"} = "" } ($form->{vc}, currency);

  $currency = $form->{currency};

  &order_links;

  $form->{currency}     = $currency;
  $form->{exchangerate} = "";
  $form->{forex}        = "";
  $form->{exchangerate} = $exchangerate
    if (
        $form->{forex} = (
                  $exchangerate =
                    $form->check_exchangerate(
                    \%myconfig, $form->{currency}, $form->{transdate}, $buysell
                    )));

  &prepare_order;
  &display_form;

  $lxdebug->leave_sub();
}

sub quotation {
  $lxdebug->enter_sub();
  if ($form->{second_run}) {
    $form->{print_and_post} = 0;
  }
  map { delete $form->{$_} } qw(id printed emailed queued);

  if ($form->{script} eq 'ir.pl' || $form->{type} eq 'purchase_order') {
    $form->{title} = $locale->text('Add Request for Quotation');
    $form->{vc}    = 'vendor';
    $form->{type}  = 'request_quotation';
    $buysell       = 'sell';
  }
  if ($form->{script} eq 'is.pl' || $form->{type} eq 'sales_order') {
    $form->{title} = $locale->text('Add Quotation');
    $form->{vc}    = 'customer';
    $form->{type}  = 'sales_quotation';
    $buysell       = 'buy';
  }

  $form->{cp_id} *= 1;

  $form->{script} = 'oe.pl';

  $form->{shipto} = 1;

  $form->{rowcount}--;

  require "$form->{path}/$form->{script}";

  map { $form->{"select$_"} = "" } ($form->{vc}, currency);

  $currency = $form->{currency};

  &order_links;

  $form->{currency}     = $currency;
  $form->{exchangerate} = "";
  $form->{forex}        = "";
  $form->{exchangerate} = $exchangerate
    if (
        $form->{forex} = (
                  $exchangerate =
                    $form->check_exchangerate(
                    \%myconfig, $form->{currency}, $form->{transdate}, $buysell
                    )));

  &prepare_order;
  &display_form;

  $lxdebug->leave_sub();
}

sub request_for_quotation {
  quotation();
}

sub e_mail {
  $lxdebug->enter_sub();
  if ($form->{second_run}) {
    $form->{print_and_post} = 0;
    $form->{resubmit}       = 0;
  }
  if ($myconfig{role} eq 'admin') {
    $bcc = qq|
 	  <th align=right nowrap=true>| . $locale->text('Bcc') . qq|</th>
	  <td><input name=bcc size=30 value="$form->{bcc}"></td>
|;
  }

  if ($form->{formname} =~ /(pick|packing|bin)_list/) {
    $form->{email} = $form->{shiptoemail} if $form->{shiptoemail};
  }

  $name = $form->{ $form->{vc} };
  $name =~ s/--.*//g;
  $title = $locale->text('E-mail') . " $name";

  $form->{oldmedia} = $form->{media};
  $form->{media}    = "email";

  $form->header;

  print qq|
<body>

<form method=post action=$form->{script}>

<table width=100%>
  <tr class=listtop>
    <th class=listtop>$title</th>
  </tr>
  <tr height="5"></tr>
  <tr>
    <td>
      <table width=100%>
	<tr>
	  <th align=right nowrap>| . $locale->text('To') . qq|</th>
	  <td><input name=email size=30 value="$form->{email}"></td>
	  <th align=right nowrap>| . $locale->text('Cc') . qq|</th>
	  <td><input name=cc size=30 value="$form->{cc}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Subject') . qq|</th>
	  <td><input name=subject size=30 value="$form->{subject}"></td>
	  $bcc
	</tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
      <table width=100%>
	<tr>
	  <th align=left nowrap>| . $locale->text('Message') . qq|</th>
	</tr>
	<tr>
	  <td><textarea name=message rows=15 cols=60 wrap=soft>$form->{message}</textarea></td>
	</tr>
      </table>
    </td>
  </tr>
  <tr>
    <td>
|;

  &print_options;

  map { delete $form->{$_} }
    qw(action email cc bcc subject message formname sendmode format header override);

  # save all other variables
  foreach $key (keys %$form) {
    $form->{$key} =~ s/\"/&quot;/g;
    print qq|<input type=hidden name=$key value="$form->{$key}">\n|;
  }

  print qq|
    </td>
  </tr>
  <tr>
    <td><hr size=3 noshade></td>
  </tr>
</table>

<input type=hidden name=nextsub value=send_email>

<br>
<input name=action class=submit type=submit value="|
    . $locale->text('Continue') . qq|">
</form>

</body>
</html>
|;

  $lxdebug->leave_sub();
}

sub send_email {
  $lxdebug->enter_sub();

  $old_form = new Form;

  map { $old_form->{$_} = $form->{$_} } keys %$form;
  $old_form->{media} = $form->{oldmedia};

  &print_form($old_form);

  $lxdebug->leave_sub();
}

sub print_options {
  $lxdebug->enter_sub();
  $form->{sendmode} = "attachment";
  $form->{copies}   = 3 unless $form->{copies};

  $form->{PD}{ $form->{formname} } = "selected";
  $form->{DF}{ $form->{format} }   = "selected";
  $form->{OP}{ $form->{media} }    = "selected";
  $form->{SM}{ $form->{sendmode} } = "selected";

  if ($form->{type} eq 'purchase_order') {
    $type = qq|<select name=formname>
	    <option value=purchase_order $form->{PD}{purchase_order}>|
      . $locale->text('Purchase Order') . qq|
	    <option value=bin_list $form->{PD}{bin_list}>|
      . $locale->text('Bin List');
  }

  if ($form->{type} eq 'credit_note') {
    $type = qq|<select name=formname>
	    <option value=credit_note $form->{PD}{credit_note}>|
      . $locale->text('Credit Note');
  }

  if ($form->{type} eq 'sales_order') {
    $type = qq|<select name=formname>
	    <option value=sales_order $form->{PD}{sales_order}>|
      . $locale->text('Confirmation') . qq|
      <option value=proforma $form->{PD}{proforma}>|
      . $locale->text('Proforma Invoice') . qq|
	    <option value=pick_list $form->{PD}{pick_list}>|
      . $locale->text('Pick List') . qq|
	    <option value=packing_list $form->{PD}{packing_list}>|
      . $locale->text('Packing List');
  }

  if ($form->{type} =~ /_quotation$/) {
    $type = qq|<select name=formname>
	    <option value="$`_quotation" $form->{PD}{"$`_quotation"}>|
      . $locale->text('Quotation');
  }

  if ($form->{type} eq 'invoice') {
    $type = qq|<select name=formname>
	    <option value=invoice $form->{PD}{invoice}>|
      . $locale->text('Invoice') . qq|
      <option value=proforma $form->{PD}{proforma}>|
      . $locale->text('Proforma Invoice') . qq|
      <option value=packing_list $form->{PD}{packing_list}>|
      . $locale->text('Packing List');
  }

  if ($form->{type} eq 'invoice' && $form->{storno}) {
    $type = qq|<select name=formname>
	    <option value=storno_invoice $form->{PD}{storno_invoice}>|
      . $locale->text('Storno Invoice') . qq|
      <option value=storno_packing_list $form->{PD}{storno_packing_list}>|
      . $locale->text('Storno Packing List');
  }

  if ($form->{type} eq 'credit_note') {
    $type = qq|<select name=formname>
	    <option value=credit_note $form->{PD}{credit_note}>|
      . $locale->text('Credit Note');
  }

  if ($form->{type} eq 'ship_order') {
    $type = qq|<select name=formname>
	    <option value=pick_list $form->{PD}{pick_list}>|
      . $locale->text('Pick List') . qq|
	    <option value=packing_list $form->{PD}{packing_list}>|
      . $locale->text('Packing List');
  }

  if ($form->{type} eq 'receive_order') {
    $type = qq|<select name=formname>
	    <option value=bin_list $form->{PD}{bin_list}>|
      . $locale->text('Bin List');
  }

  if ($form->{media} eq 'email') {
    $media = qq|<select name=sendmode>
	    <option value=attachment $form->{SM}{attachment}>|
      . $locale->text('Attachment') . qq|
	    <option value=inline $form->{SM}{inline}>| . $locale->text('In-line');
  } else {
    $media = qq|<select name=media>
	    <option value=screen $form->{OP}{screen}>| . $locale->text('Screen');
    if (scalar(keys (%{ $form->{printers} })) !=0 && $latex_templates) {
      $media .= qq|
            <option value=printer $form->{OP}{printer}>|
        . $locale->text('Printer');
    }
    if ($latex_templates) {
      $media .= qq|
            <option value=queue $form->{OP}{queue}>| . $locale->text('Queue');
    }
  }

  $format = qq|<select name=format>|;
  if ($opendocument_templates && $openofficeorg_writer_bin &&
      $xvfb_bin && (-x $openofficeorg_writer_bin) && (-x $xvfb_bin)) {
    $format .= qq|<option value=opendocument_pdf | .
      $form->{DF}{"opendocument_pdf"} . qq|>| .
      $locale->text("PDF (OpenDocument/OASIS)") . qq|</option>|;
  }

  if ($latex_templates) {
    $format .= qq|<option value=pdf $form->{DF}{pdf}>| .
      $locale->text('PDF') . qq|</option>|;
  }

  $format .= qq|<option value=html $form->{DF}{html}>HTML</option>|;

  if ($latex_templates) {
    $format .= qq|<option value=postscript $form->{DF}{postscript}>| .
      $locale->text('Postscript') . qq|</option>|;
  }

  if ($opendocument_templates) {
    $format .= qq|<option value=opendocument $form->{DF}{opendocument}>| .
      $locale->text("OpenDocument/OASIS") . qq|</option>|;
  }
  $format .= qq|</select>|;

  if (scalar(keys (%{ $form->{languages} })) !=0) {
    $language_select = qq|<select name=language_id>
		<option value=""></option>}|;
    foreach $item (@{ $form->{languages} }) {
      if ($form->{language_id} eq $item->{id}) {
        $language_select .= qq|<option value="$item->{id}" selected>$item->{description}</option>|;
      } else {
        $language_select .= qq|<option value="$item->{id}">$item->{description}</option>|;
      }
    }
  }

  if (scalar(keys (%{ $form->{printers} })) !=0) {

    $printer_select = qq|<select name=printer_id>
                  <option value=""></option>|;
    foreach $item (@{ $form->{printers} }) {
      $printer_select .= qq|<option value="$item->{id}">$item->{printer_description}</option>|;
    }
  }



  print qq|
<table width=100% cellspacing=0 cellpadding=0>
  <tr>
    <td>
      <table>
	<tr>
	  <td>$type</select></td>|;
  if (scalar(keys (%{ $form->{languages} })) !=0) {
  print qq|
          <td>${language_select}</select></td>|;
  }
  print qq|
	  <td>$format</select></td>
	  <td>$media</select></td>|;
  if (scalar(keys (%{ $form->{printers} })) !=0) {
  print qq|
	  <td>$printer_select</select></td>
|;
  }

  if (scalar(keys (%{ $form->{printers} })) !=0 && $latex_templates && $form->{media} ne 'email') {
    print qq|
	  <td>| . $locale->text('Copies') . qq|
	  <input name=copies size=2 value=$form->{copies}></td>
|;
  }

  $form->{groupitems} = "checked" if $form->{groupitems};

  print qq|
          <td>| . $locale->text('Group Items') . qq|</td>
          <td><input name=groupitems type=checkbox class=checkbox $form->{groupitems}></td>
        </tr>
      </table>
    </td>
    <td align=right>
      <table>
        <tr>
|;

  if ($form->{printed} =~ /$form->{formname}/) {
    print qq|
	  <th>\|| . $locale->text('Printed') . qq|\|</th>
|;
  }

  if ($form->{emailed} =~ /$form->{formname}/) {
    print qq|
	  <th>\|| . $locale->text('E-mailed') . qq|\|</th>
|;
  }

  if ($form->{queued} =~ /$form->{formname}/) {
    print qq|
	  <th>\|| . $locale->text('Queued') . qq|\|</th>
|;
  }

  print qq|
        </tr>
      </table>
    </td>
  </tr>
</table>
|;

  $lxdebug->leave_sub();
}

sub print {
  $lxdebug->enter_sub();

  # if this goes to the printer pass through
  if ($form->{media} eq 'printer' || $form->{media} eq 'queue') {
    $form->error($locale->text('Select postscript or PDF!'))
      if ($form->{format} !~ /(postscript|pdf)/);

    $old_form = new Form;
    map { $old_form->{$_} = $form->{$_} } keys %$form;
  }

  if (!$form->{id} || (($form->{formname} eq "proforma") && !$form->{proforma} && (($form->{type} =~ /_order$/) || ($form->{type} =~ /_quotation$/)))) {
    if ($form->{formname} eq "proforma") {
      $form->{proforma} = 1;
    }
    $form->{print_and_save} = 1;
    my $formname = $form->{formname};
    &save();
    $form->{formname} = $formname;
    &edit();
    exit;
  }

  &print_form($old_form);

  $lxdebug->leave_sub();
}

sub print_form {
  $lxdebug->enter_sub();
  my ($old_form) = @_;

  $inv       = "inv";
  $due       = "due";
  $numberfld = "invnumber";

  $display_form =
    ($form->{display_form}) ? $form->{display_form} : "display_form";

  # $form->{"notes"} will be overridden by the customer's/vendor's "notes" field. So save it here.
  $form->{ $form->{"formname"} . "notes" } = $form->{"notes"};

  if ($form->{formname} eq "invoice") {
    $form->{label} = $locale->text('Invoice');
  }
  if ($form->{formname} eq "packing_list") {

    # this is from an invoice
    $form->{label} = $locale->text('Packing List');
  }
  if ($form->{formname} eq 'sales_order') {
    $inv                  = "ord";
    $due                  = "req";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{label}        = $locale->text('Sales Order');
    $numberfld            = "sonumber";
    $order                = 1;
  }

  if (($form->{type} eq 'invoice') && ($form->{formname} eq 'proforma') ) {
    $inv                  = "inv";
    $due                  = "due";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{"invdate"}    = $form->{transdate};
    $form->{label}        = $locale->text('Proforma Invoice');
    $numberfld            = "sonumber";
    $order                = 0;
  }

  if (($form->{type} eq 'sales_order') && ($form->{formname} eq 'proforma') ) {
    $inv                  = "inv";
    $due                  = "due";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{"invdate"}    = $form->{transdate};
    $form->{invnumber}    = $form->{ordnumber};
    $form->{label}        = $locale->text('Proforma Invoice');
    $numberfld            = "sonumber";
    $order                = 1;
  }

  if ($form->{formname} eq 'packing_list' && $form->{type} ne 'invoice') {

    # we use the same packing list as from an invoice
    $inv = "ord";
    $due = "req";
    $form->{invdate} = $form->{"${inv}date"} = $form->{transdate};
    $form->{label} = $locale->text('Packing List');
    $order = 1;
    # set invnumber for template packing_list 
    $form->{invnumber}   = $form->{ordnumber};
  }
  if ($form->{formname} eq 'pick_list') {
    $inv                  = "ord";
    $due                  = "req";
    $form->{"${inv}date"} =
      ($form->{transdate}) ? $form->{transdate} : $form->{invdate};
    $form->{label} = $locale->text('Pick List');
    $order = 1 unless $form->{type} eq 'invoice';
  }
  if ($form->{formname} eq 'purchase_order') {
    $inv                  = "ord";
    $due                  = "req";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{label}        = $locale->text('Purchase Order');
    $numberfld            = "ponumber";
    $order                = 1;
  }
  if ($form->{formname} eq 'bin_list') {
    $inv                  = "ord";
    $due                  = "req";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{label}        = $locale->text('Bin List');
    $order                = 1;
  }
  if ($form->{formname} eq 'sales_quotation') {
    $inv                  = "quo";
    $due                  = "req";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{label}        = $locale->text('Quotation');
    $numberfld            = "sqnumber";
    $order                = 1;
  }

  if (($form->{type} eq 'sales_quotation') && ($form->{formname} eq 'proforma') ) {
    $inv                  = "quo";
    $due                  = "req";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{"invdate"} = $form->{transdate};
    $form->{label}        = $locale->text('Proforma Invoice');
    $numberfld            = "sqnumber";
    $order                = 1;
  }

  if ($form->{formname} eq 'request_quotation') {
    $inv                  = "quo";
    $due                  = "req";
    $form->{"${inv}date"} = $form->{transdate};
    $form->{label}        = $locale->text('Quotation');
    $numberfld            = "rfqnumber";
    $order                = 1;
  }

  $form->isblank("email", $locale->text('E-mail address missing!'))
    if ($form->{media} eq 'email');
  $form->isblank("${inv}date",
                 $locale->text($form->{label} . ' Date missing!'));

  # $locale->text('Invoice Number missing!')
  # $locale->text('Invoice Date missing!')
  # $locale->text('Packing List Number missing!')
  # $locale->text('Packing List Date missing!')
  # $locale->text('Order Number missing!')
  # $locale->text('Order Date missing!')
  # $locale->text('Quotation Number missing!')
  # $locale->text('Quotation Date missing!')

  # assign number
  if (!$form->{"${inv}number"} && !$form->{preview}) {
    $form->{"${inv}number"} = $form->update_defaults(\%myconfig, $numberfld);
    if ($form->{media} ne 'email') {

      # get pricegroups for parts
      IS->get_pricegroups_for_parts(\%myconfig, \%$form);

      # build up html code for prices_$i
      set_pricegroup($form->{rowcount});

      $form->{rowcount}--;

      &{"$display_form"};
      exit;
    }
  }

  &validate_items;

  # Save the email address given in the form because it should override the setting saved for the customer/vendor.
  my ($saved_email, $saved_cc, $saved_bcc) =
    ($form->{"email"}, $form->{"cc"}, $form->{"bcc"});

  $language_saved = $form->{language_id};
  $payment_id_saved = $form->{payment_id};

  &{"$form->{vc}_details"};

  $form->{language_id} = $language_saved;
  $form->{payment_id} = $payment_id_saved;

  $form->{"email"} = $saved_email if ($saved_email);
  $form->{"cc"}    = $saved_cc    if ($saved_cc);
  $form->{"bcc"}   = $saved_bcc   if ($saved_bcc);

  my ($language_tc, $output_numberformat, $output_dateformat, $output_longdates);
  if ($form->{"language_id"}) {
    ($language_tc, $output_numberformat, $output_dateformat, $output_longdates) =
      AM->get_language_details(\%myconfig, $form, $form->{language_id});
  } else {
    $output_dateformat = $myconfig{"dateformat"};
    $output_numberformat = $myconfig{"numberformat"};
    $output_longdates = 1;
  }

  ($form->{employee}) = split /--/, $form->{employee};
  ($form->{warehouse}, $form->{warehouse_id}) = split /--/, $form->{warehouse};

  # create the form variables
  if ($order) {
    OE->order_details(\%myconfig, \%$form);
  } else {
    IS->invoice_details(\%myconfig, \%$form, $locale);
  }

  if ($form->{shipto_id}) {
    $form->get_shipto(\%myconfig);
  }

  @a = qw(name street zipcode city country);

  $shipto = 1;

  # if there is no shipto fill it in from billto
  foreach $item (@a) {
    if ($form->{"shipto$item"}) {
      $shipto = 0;
      last;
    }
  }

  if ($shipto) {
    if (   $form->{formname} eq 'purchase_order'
        || $form->{formname} eq 'request_quotation') {
      $form->{shiptoname}   = $myconfig{company};
      $form->{shiptostreet} = $myconfig{address};
    } else {
      map { $form->{"shipto$_"} = $form->{$_} } @a;
    }
  }

  $form->{notes} =~ s/^\s+//g;

  map({ $form->{$_} =~ s/\\n/\n/g; } qw(company address));

  $form->{templates} = "$myconfig{templates}";

  $form->{language} = $form->get_template_language(\%myconfig);
  $form->{printer_code} = $form->get_printer_code(\%myconfig);

  if ($form->{language} ne "") {
    map({ $form->{"unit"}->[$_] =
            AM->translate_units($form, $form->{"language"},
                                $form->{"unit"}->[$_], $form->{"qty"}->[$_]); }
        (0..scalar(@{$form->{"unit"}}) - 1));
    $form->{language} = "_" . $form->{language};
  }

  # Format dates.
  format_dates($output_dateformat, $output_longdates,
               qw(invdate orddate quodate pldate duedate reqdate transdate
                  shippingdate deliverydate validitydate paymentdate
                  datepaid transdate_oe deliverydate_oe
                  employee_startdate employee_enddate
                  ),
               grep({ /^datepaid_\d+$/ ||
                        /^transdate_oe_\d+$/ ||
                        /^deliverydate_oe_\d+$/ ||
                        /^reqdate_\d+$/ ||
                        /^deliverydate_\d+$/ ||
                        /^transdate_\d+$/
                    } keys(%{$form})));

  reformat_numbers($output_numberformat, 2,
                   qw(invtotal ordtotal quototal subtotal linetotal
                      listprice sellprice netprice discount
                      tax taxbase),
                   grep({ /^linetotal_\d+$/ ||
                            /^listprice_\d+$/ ||
                            /^sellprice_\d+$/ ||
                            /^netprice_\d+$/ ||
                            /^taxbase_\d+$/ ||
                            /^discount_\d+$/ ||
                            /^tax_\d+$/
                        } keys(%{$form})));

  reformat_numbers($output_numberformat, undef,
                   qw(qty),
                   grep({ /^qty_\d+$/
                        } keys(%{$form})));

  if ($form->{printer_code} ne "") {
    $form->{printer_code} = "_" . $form->{printer_code};
  }

  $form->{IN} = "$form->{formname}$form->{language}$form->{printer_code}.html";
  if ($form->{format} eq 'postscript') {
    $form->{postscript} = 1;
    $form->{IN} =~ s/html$/tex/;
  } elsif ($form->{"format"} =~ /pdf/) {
    $form->{pdf} = 1;
    if ($form->{"format"} =~ /opendocument/) {
      $form->{IN} =~ s/html$/odt/;
    } else {
      $form->{IN} =~ s/html$/tex/;
    }
  } elsif ($form->{"format"} =~ /opendocument/) {
    $form->{"opendocument"} = 1;
    $form->{"IN"} =~ s/html$/odt/;
  }

  if ($form->{media} eq 'printer') {
    $form->{OUT} = "| $form->{printer_command} &>/dev/null";
    $form->{printed} .= " $form->{formname}";
    $form->{printed} =~ s/^ //;
  }
  $printed = $form->{printed};

  if ($form->{media} eq 'email') {
    $form->{subject} = qq|$form->{label} $form->{"${inv}number"}|
      unless $form->{subject};

    $form->{OUT} = "$sendmail";

    $form->{emailed} .= " $form->{formname}";
    $form->{emailed} =~ s/^ //;
  }
  $emailed = $form->{emailed};

  if ($form->{media} eq 'queue') {
    %queued = split / /, $form->{queued};

    if ($filename = $queued{ $form->{formname} }) {
      $form->{queued} =~ s/$form->{formname} $filename//;
      unlink "$spool/$filename";
      $filename =~ s/\..*$//g;
    } else {
      $filename = time;
      $filename .= $$;
    }

    $filename .= ($form->{postscript}) ? '.ps' : '.pdf';
    $form->{OUT} = ">$spool/$filename";

    # add type
    $form->{queued} .= " $form->{formname} $filename";

    $form->{queued} =~ s/^ //;
  }
  $queued = $form->{queued};

  $form->parse_template(\%myconfig, $userspath);

  $form->{callback} = "";

  if ($form->{media} eq 'email') {
    $form->{message} = $locale->text('sent') unless $form->{message};
  }
  $message = $form->{message};

  # if we got back here restore the previous form
  if ($form->{media} =~ /(printer|email|queue)/) {

    $form->update_status(\%myconfig)
      if ($form->{media} eq 'queue' && $form->{id});

    if ($old_form) {

      $old_form->{"${inv}number"} = $form->{"${inv}number"};

      # restore and display form
      map { $form->{$_} = $old_form->{$_} } keys %$old_form;

      $form->{queued}  = $queued;
      $form->{printed} = $printed;
      $form->{emailed} = $emailed;
      $form->{message} = $message;

      $form->{rowcount}--;
      map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) }
        qw(exchangerate creditlimit creditremaining);

      for $i (1 .. $form->{paidaccounts}) {
        map {
          $form->{"${_}_$i"} =
            $form->parse_amount(\%myconfig, $form->{"${_}_$i"})
        } qw(paid exchangerate);
      }

      &{"$display_form"};
      exit;
    }

    $msg =
      ($form->{media} eq 'printer')
      ? $locale->text('sent to printer')
      : $locale->text('emailed to') . " $form->{email}";
    $form->redirect(qq|$form->{label} $form->{"${inv}number"} $msg|);
  }
  if ($form->{printing}) {
   &{"$display_form"};
   exit; 
  }

  $lxdebug->leave_sub();
}

sub customer_details {
  $lxdebug->enter_sub();
  IS->customer_details(\%myconfig, \%$form);
  $lxdebug->leave_sub();
}

sub vendor_details {
  $lxdebug->enter_sub();

  IR->vendor_details(\%myconfig, \%$form);

  $lxdebug->leave_sub();
}

sub post_as_new {
  $lxdebug->enter_sub();

  $form->{postasnew} = 1;
  map { delete $form->{$_} } qw(printed emailed queued);

  &post;

  $lxdebug->leave_sub();
}

sub ship_to {
  $lxdebug->enter_sub();
  if ($form->{second_run}) {
    $form->{print_and_post} = 0;
  }

  $title = $form->{title};
  $form->{title} = $locale->text('Ship to');

  map { $form->{$_} = $form->parse_amount(\%myconfig, $form->{$_}) }
    qw(exchangerate creditlimit creditremaining);

  # get details for name
  &{"$form->{vc}_details"};

  $number =
    ($form->{vc} eq 'customer')
    ? $locale->text('Customer Number')
    : $locale->text('Vendor Number');

  # get pricegroups for parts
  IS->get_pricegroups_for_parts(\%myconfig, \%$form);

  # build up html code for prices_$i
  set_pricegroup($form->{rowcount});

  $nextsub = ($form->{display_form}) ? $form->{display_form} : "display_form";

  $form->{rowcount}--;

  $form->header;

  print qq|
<body>

<form method=post action=$form->{script}>

<table width=100%>
  <tr>
    <td>
      <table>
	<tr class=listheading>
	  <th class=listheading colspan=2 width=50%>|
    . $locale->text('Billing Address') . qq|</th>
	  <th class=listheading width=50%>|
    . $locale->text('Shipping Address') . qq|</th>
	</tr>
	<tr height="5"></tr>
	<tr>
	  <th align=right nowrap>$number</th>
	  <td>$form->{"$form->{vc}number"}</td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Company Name') . qq|</th>
	  <td>$form->{name}</td>
	  <td><input name=shiptoname size=35 value="$form->{shiptoname}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Department') . qq|</th>
	  <td>$form->{department_1}</td>
	  <td><input name=shiptodepartment_1 size=35 value="$form->{shiptodepartment_1}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>&nbsp;</th>
	  <td>$form->{department_2}</td>
	  <td><input name=shiptodepartment_2 size=35 value="$form->{shiptodepartment_2}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Street') . qq|</th>
	  <td>$form->{street}</td>
	  <td><input name=shiptostreet size=35 value="$form->{shiptostreet}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Zipcode') . qq|</th>
	  <td>$form->{zipcode}</td>
	  <td><input name=shiptozipcode size=35 value="$form->{shiptozipcode}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('City') . qq|</th>
	  <td>$form->{city}</td>
	  <td><input name=shiptocity size=35 value="$form->{shiptocity}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Country') . qq|</th>
	  <td>$form->{country}</td>
	  <td><input name=shiptocountry size=35 value="$form->{shiptocountry}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Contact') . qq|</th>
	  <td>$form->{contact}</td>
	  <td><input name=shiptocontact size=35 value="$form->{shiptocontact}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Phone') . qq|</th>
	  <td>$form->{"$form->{vc}phone"}</td>
	  <td><input name=shiptophone size=20 value="$form->{shiptophone}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('Fax') . qq|</th>
	  <td>$form->{"$form->{vc}fax"}</td>
	  <td><input name=shiptofax size=20 value="$form->{shiptofax}"></td>
	</tr>
	<tr>
	  <th align=right nowrap>| . $locale->text('E-mail') . qq|</th>
	  <td>$form->{email}</td>
	  <td><input name=shiptoemail size=35 value="$form->{shiptoemail}"></td>
	</tr>
      </table>
    </td>
  </tr>
</table>

<input type=hidden name=nextsub value=$nextsub>
|;

  # delete shipto
  map { delete $form->{$_} }
    qw(shiptoname shiptostreet shiptozipcode shiptocity shiptocountry shiptocontact shiptophone shiptofax shiptoemail shiptodepartment_1 shiptodepartment_2 header);
  $form->{title} = $title;

  foreach $key (keys %$form) {
    $form->{$key} =~ s/\"/&quot;/g;
    print qq|<input type=hidden name=$key value="$form->{$key}">\n|;
  }

  print qq|

<hr size=3 noshade>

<br>
<input class=submit type=submit name=action value="|
    . $locale->text('Continue') . qq|">
</form>

</body>
</html>
|;

  $lxdebug->leave_sub();
}

sub new_license {
  $lxdebug->enter_sub();

  my $row = shift;

  # change callback
  $form->{old_callback} = $form->escape($form->{callback}, 1);
  $form->{callback} = $form->escape("$form->{script}?action=display_form", 1);
  $form->{old_callback} = $form->escape($form->{old_callback}, 1);

  # delete action
  delete $form->{action};
  $customer = $form->{customer};
  map { $form->{"old_$_"} = $form->{"${_}_$row"} } qw(partnumber description);

  # save all other form variables in a previousform variable
  $form->{row} = $row;
  foreach $key (keys %$form) {

    # escape ampersands
    $form->{$key} =~ s/&/%26/g;
    $previousform .= qq|$key=$form->{$key}&|;
  }
  chop $previousform;
  $previousform = $form->escape($previousform, 1);

  $form->{script} = "licenses.pl";

  map { $form->{$_} = $form->{"old_$_"} } qw(partnumber description);
  map { $form->{$_} = $form->escape($form->{$_}, 1) }
    qw(partnumber description);
  $form->{callback} =
    qq|$form->{script}?login=$form->{login}&path=$form->{path}&password=$form->{password}&action=add&vc=$form->{db}&$form->{db}_id=$form->{id}&$form->{db}=$name&type=$form->{type}&customer=$customer&partnumber=$form->{partnumber}&description=$form->{description}&previousform="$previousform"&initial=1|;
  $form->redirect;

  $lxdebug->leave_sub();
}

sub relink_accounts {
  $lxdebug->enter_sub();

  $form->{"taxaccounts"} =~ s/\s*$//;
  $form->{"taxaccounts"} =~ s/^\s*//;
  foreach my $accno (split(/\s*/, $form->{"taxaccounts"})) {
    map({ delete($form->{"${accno}_${_}"}); } qw(rate description taxnumber));
  }
  $form->{"taxaccounts"} = "";

  for (my $i = 1; $i <= $form->{"rowcount"}; $i++) {
    if ($form->{"id_$i"}) {
      IC->retrieve_accounts(\%myconfig, $form, $form->{"id_$i"}, $i, 1);
    }
  }

  $lxdebug->leave_sub();
}
