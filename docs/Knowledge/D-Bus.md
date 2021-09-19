# D-Bus

* Service
* Object (path)
* Interface

1. Every service has the root path `'/'`, even if there are no interfaces
   there. Introspecting the root path will return a list of nodes, if that's
   the case.
2. Every object path should support at least
   org.freedesktop.DBus.Introspectable(.Introspect) and
   org.freedesktop.DBus.Properties

Get entities on the bus:

```
dbus-send [--system] --print-reply --dest=org.freedesktop.DBus / \
          org.freedesktop.DBus.ListNames
```

Example: Get properties of a service:

```
org.bluez
|
--/org/bluez/hci0/dev_70_1F_3C_F6_41_98/fd6
  |
  --org.bluez.MediaTransport1
```

```
dbus-send --system --type=method_call --print-reply --dest=org.bluez \
          / org.freedesktop.DBus.ObjectManager.GetManagedObjects
```

```
dbus-send --system --type=method_call --print-reply --dest=org.bluez \
          /org/bluez/dev_70_1F_3C_F6_41_98/fd6 \
          org.freedesktop.DBus.Properties.GetAll \
          string:'org.bluez.MediaTransport1'
```
