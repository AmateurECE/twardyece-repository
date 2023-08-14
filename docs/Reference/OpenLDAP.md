---
title: OpenLDAP
---

This document goes over techniques for managing an OpenLDAP server. Some of the
procedures here can apply to Microsoft Active Directory, but since I'm not
using that, I can't be sure.

Remember that the directory works just like that--a directory of information.
In general, directories in LDAP are specified using reverse-domain names. For
example, in `'dc=edtwardy,dc=hopto,dc=org'`, the location
`dc=edtwardy` is a sublocation of `dc=hopto`, which is, of
course, a sublocation of `dc=org`.

Much of the procedures for altering information in the directory must be placed
in LDIF files, which must be specified to system commands, such as
`ldapadd` or `ldapmodify`.

All additions and modifications require either permissions to make the desired
operations in the directory, or knowledge of the administrator password. For my
directory, the administrator DN is
`'cn=admin,dc=edtwardy,dc=hopto,dc=org'`.

# Reconfiguring and Finding North
When `slapd` is installed, especially on Debian, apt may not request
full configuration from the user, and may incorrectly determine the DNS domain
name of the system. To reconfigure the package, simply use `dpkg`:

```
dpkg-reconfigure slapd
```

Next, it can be useful to determine the DN of the server:

```
ldapsearch -x -s base -b "" namingContexts
```

To talk to a `slapd` daemon running on another machine:

```
ldapsearch -h <hostName> ...
```

For a server with the FQDN `edtwardy.hopto.org`, this would produce
output like:

```ldif
...
#
dn:
namingContexts: dc=edtwardy,dc=hopto,dc=org
...
```

# Searching

To search for entities in the directory:
```
ldapsearch -x -LLL -b 'ou=people,dc=edtwardy,dc=hopto,dc=org' '(uid=*)' uid
```

Sudo should not be required. This binds anonymously to the directory and
searches the organizational unit (`ou=`) `people` in the domain
`edtwardy.hopto.org`, returning the `uid` of every entry with
any `uid`. If the last positional argument is not specified, all
attributes will be returned. The first positional argument is the filter,
describing which entries are returned from the results.

# Creation of Entities

The procedure for creating entities is the same, regardless of the type of
entity. The user must generate an LDIF file containing information about the
entity to generate, and then specify this file on the command line using the
`ldapadd` command. For example, an LDIF file named
`operations.ldif` would be used like so:

```
ldapadd -W -D 'cn=admin,dc=edtwardy,dc=hopto,dc=org' -f operations.ldif
```

## Creating an Organizational Unit

Generally speaking, the Organizational Unit is the entity at the top level of
your domain (i.e. within `'dc=edtwardy,dc=hopto,dc=org'`, there are a
number of Organizational Groups, `'ou=*'`).

The LDIF file for creating an organizational unit would look something like the
following. Of course, the information specified may differ between schemas and
directories, but this should be valid on all OpenLDAP systems:

```ldif
dn: ou=groups,dc=edtwardy,dc=hopto,dc=org
objectClass: top
objectClass: organizationalUnit
ou: groups
description: Groups
```

This will create the organizational unit `Groups` (`ou=groups`)
in the directory. I have discovered that it is not necessary to specify
`ou: groups` in the LDIF, as this is inferred.

## Creating a Group

To create a group, one must generate an LDIF file like the following, which
provides basic information about the group to create. In order for this to
work, the organizational unit `groups` must exist.

```ldif
dn: cn=Bookmarks,ou=groups,dc=edtwardy,dc=hopto,dc=org
objectClass: top
objectClass: posixGroup
gidNumber: 678
```

## Creating a User

The procedure is the same. This LDIF generates a user whose name is Ethan
Twardy, whose `uid` is edtwardy. In order for this to succeed, the
organizational unit `people` must exist.

```ldif
dn: uid=edtwardy,ou=people,dc=edtwardy,dc=hopto,dc=org
objectclass: top
objectclass: person
objectclass: organizationalPerson
objectclass: inetOrgPerson
cn: Ethan
sn: Twardy
```

# Modifying an Entity

This procedure is very similar to creation. The only difference is that the
`ldapmodify` program is used instead. Observe:

```
ldapmodify -W -D 'cn=admin,dc=edtwardy,dc=hopto,dc=org' -f operations.ldif
```

## Adding a User to a Group

This adds the user `edtwardy` to the group `Bookmarks`.
Obviously, both the group and the user must exist prior to attempting this
operation.

```ldif
dn: cn=Bookmarks,ou=groups,dc=edtwardy,dc=hopto,dc=org
changetype: modify
add: memberuid
memberuid: edtwardy
```

# Deletion

## Of a User

The OpenLDAP distribution provides a convenient tool, `ldapdelete`,
which is used to delete entries from the directory. The example below would
delete the user with the `uid` `user2` (which exists in the
organizational unit `people`, so forth) from the directory. This does
not delete this member's `uid` from any groups which may contain it.

```
ldapdelete -D 'cn=admin,dc=edtwardy,dc=hopto,dc=org' -W \
  'uid=user2,ou=people,dc=edtwardy,dc=hopto,dc=org'
```

## Of a User from a Group

The LDIF file for performing this operation is provided below. The only
difference between it and the LDIF file for adding a user to the group is the
line `delete: memberuid`, in which the directive `add`
was changed to be `delete`. This operation is completed in the normal
way using `ldapmodify`.

```ldif
dn: cn=Bookmarks,ou=groups,dc=edtwardy,dc=hopto,dc=org
changetype: modify
delete: memberuid
memberuid: edtwardy
```

# Changing User Passwords

To change the password of the user `edtwardy` using the credentials of
the `admin` user:

```
ldappasswd  -W -D 'cn=admin,dc=edtwardy,dc=hopto,dc=org' -S \
  'uid=edtwardy,ou=people,dc=edtwardy,dc=hopto,dc=org'
```
