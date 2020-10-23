# Equitrac config monitor Solarwinds
This is a script and APM template for monitoring the config of an Equitrac enabled printer.
This will alert if the config of a printer is cleared out due to a current bug.

## Download
You can download the template from the [releases page](/releases) under assets.

## Checks used
The checks are hardcoded in the template script.
Modify them as needed on line [line 82-84](./blob/main/data/equitrac-status-solarwinds.ps1#L82), and the network error at [line 55](./blob/main/data/equitrac-status-solarwinds.ps1#L55)
Currently it checks if (OR):
- The Server URL starts with `0.`
- The Manager ID starts with `1234`
- The Scan To Email Originator is empty
- The request failed

These can be prioritized differently as needed under the component settings.
Output value `0` is OK, `1` is error on that field.

## Usage in Solarwinds
### Importing the template
1. Go to "SAM Settings".
2. Then "Manage Templates" under "APPLICATION MONITOR TEMPLATES".
3. Import the file from the toolbar (at the top of the table).
4. Now add assign this template to a Node or a group of Nodes.
5. Add a new credential, where username can be anything and password is the Equitrac local printer password.

## License
[MIT](LICENSE)