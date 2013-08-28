Import-Module ShowUI -Min 1.4


UniformGrid -DataContext @{
    # Initialize the variables: (No $, because you're defining a hashtable)
    CommandList = get-command
    cID = 0
} -ControlName CommandBrowser -Columns 5 {

    button "First" -name first -On_Click {
        $CommandId.Text = $this.DataContext.cID = 0
        $CommandName.Text = $this.DataContext.CommandList[$this.DataContext.cID]
    }
    button "Next" -name next -On_Click {
        if ($this.DataContext.cID -lt ($this.DataContext.CommandList.length-1)) {
            $CommandId.Text = $this.DataContext.cID += 1
            $CommandName.Text = $this.DataContext.CommandList[$this.DataContext.cID]
        }
    }
    button "Prev" -name prev -On_Click {
        if ($this.DataContext.cID -gt 0) {
            $CommandId.Text = $this.DataContext.cID -= 1
            $CommandName.Text = $this.DataContext.CommandList[$this.DataContext.cID]
        }            
    }
    button "Last" -name last -On_Click {
        $CommandId.Text = $this.DataContext.cID = $this.DataContext.CommandList.length - 1
        $CommandName.Text = $this.DataContext.CommandList[$this.DataContext.cID]
    }
    button "Quit" -name quit -On_Click  {
        # Set-UIValue to the current item
        $parent | Set-UIValue -Value $this.DataContext.CommandList[$this.DataContext.cID] -PassThru | Close-Control
    }

    Label "ID"
    TextBox -Name CommandId -Text $($this.DataContext.cID)
    
    Label "Name"
    TextBox -Name CommandName -Text $($this.DataContext.CommandList[$this.DataContext.cID])

} -Show