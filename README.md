# phonenum

A delphi library for handling phone numbers

# Table of contents
- [phonenum](#phonenum)
- [Table of contents](#table-of-contents)
- [Install](#install)
  - [Using `boss`](#using-boss)
- [Usage](#usage)
- [Standards](#standards)
  - [Representation](#representation)
  - [Country and MNC/DDD Validation](#country-and-mncddd-validation)
  - [Files and sources](#files-and-sources)
- [Tests](#tests)
- [Error handling](#error-handling)
- [TODO](#todo)

# Install

## Using `boss`
Just use the following command:

```console
$ boss install github.com/Joao-Peterson/phonenum
```

If asked for permission, you can login with your gitlab credentials. **(must be done in powershell or cmd with administrator mode)**
```console
$ boss login
> Url to login (ex: github.com): github.com
> Use SSH(y or n):
> n
> Username: your_username
> Password: your_password
```

Note: ssh isn't supported, hence the **'n'** for not using ssh. See this issue with boss: https://github.com/HashLoad/boss/issues/52.

# Usage

Here a TLDR sample usage for a sample brazillian mobile phone number, where a phone is parsed and created, printed using the brazillian and internacional representation and the country and DDD names are printed, this provides code checking for a number, checking if the country code exists and the DDD brazillian code exists also.

```pascal
procedure handlePhone();
begin
    var p: phoneNumT; 

    try
        p := phoneNumT.CreateFromBrazil('49 5769-8674');
    except
        on E: Exception do raise;
    end;

    WriteLn(p.brazilNumber);
    // 49 95769-8674

    WriteLn(p.internacionalNumber);
    // 55 49 957698674

    // error will be raised if country or brazil DDD region codes are invalid
    try
        WriteLn(p.countryName);
        // Brazil

        WriteLn(p.dddRegion);
        // Santa Catarina
    except
        on E: Exception do raise;
    end;
end;
```

# Standards

## Representation
This library uses the ITU E.212 IMSI stardard for intrnacional mobile phone numbers representation.

![](images/imsi.png)
Source: [ITU](https://www.itu.int/rec/T-REC-E.212-201609-I/en).

And furthermore, the MSIN is broken down into two parts in the code, wich are combined when using the internacional representation but separeted while using the common brazillian representation.

## Country and MNC/DDD Validation

Country code validation and naming are based on the official ITU spec and so is the MVC/DDD regional code validation and naming for brazilian regions. **So far only 3 digit country codes are supported**.

Tables for the codes and names for coutries/DDD's are in:

* [countryCodes3DigitNoDuplicates.csv](docs/countryCodes3DigitNoDuplicates.csv)
* [ddd.csv](docs/ddd.csv)

## Files and sources
All sources, standards and tables are in the [docs/](docs/) folder.

# Tests

Tests are done by the [testsU.pas](test/testsU.pas) file using [DunitX](https://github.com/VSoftTechnologies/DUnitX). Just compile the [test.dproj](test/test.dproj) project and execute the tests.

# Error handling

This library raises a `phoneE` exception type on errors, make sure to wrap things around with a `try-except` block.

# TODO

