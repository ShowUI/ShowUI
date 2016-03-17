ShowUI is _the_ PowerShell module for building user interfaces in script. It's the merger of two previous projects: PowerBoots (by Joel Bennett @Jaykul) and WPK (by James Brundage @StartAutomating), bringing the best of both these projects together to make it easier than ever to create flexible user interfaces directly from PowerShell.

ShowUI is primarily focused on building WPF user interfaces that behave as part of the PowerShell ecosystem: using data binding to expose the data on the objects that come out of PowerShell, and generating output objects into the PowerShell pipeline. 

## Your first ShowUI program

<img src="https://github.com/ShowUI/ShowUI/blob/dev/Documentation/images/ShowUI-01.png" style="float: right">

```
New-Button -Content "Hello World" -Show
```

This example is actually more verbose than it needs to be, because the `-Content` parameter in ShowUI commands is always positional, so the first non-named argument you pass will be used for that. The same is true for the `-Children` parameter of panels, and in fact, each of the other similar parameters that WPF uses to contain additional controls: Items, Blocks, and Inlines.

Additionally, each control command has an alias available without the `New-` verb, so you could just call `Button` instead of `New-Button` ... and of course, since our button doesn't do anything, we could just as easily have used a Label, and written:

```
Label "Hello World" -Show
```

Note: "Label" is also the name of an executable for labelling drives in Windows, make sure ShowUI is imported before you run that command!


## A much more practical example

Of course, labels and buttons (and images, charts and tables) are all well and good, but if you're trying to create a user interface in PowerShell the chances are that you're probably trying to make it easier for non-PowerShell users to run a script which requires data entry. Try our Get-Input command, and notice that we can create controls in "CustomControls" with a `[OutputType()]` specified, and they'll be picked up when you require them by specifying a type in the `Get-Input` hashtable.

<img src="https://github.com/ShowUI/ShowUI/blob/dev/Documentation/images/Get-Input-01.png" style="float: right">

```
$User = [ordered]@{
   FirstName = "John"
   LastName = "Doe"
   BirthDate = [DateTime]
   UserName = "JDoe"
}

Get-Input $User -Show
```

