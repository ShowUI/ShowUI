function Search-Twitter  {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [string[]]$q
    )
    
    Process {
        $query = $q -join "+OR+"
        $uri = "http://search.twitter.com/search.rss?q=$query"
        trap { continue }
        XmlDataProvider -Source $uri -XPath /rss/channel/item -ErrorAction 0
    }
}

Show {
    ListBox -DataContext {
        Search-Twitter PowerShell, Microsoft, ShowUI
    } -ItemsSource {Binding} -ItemTemplate {
        DataTemplate { 
            Label -Content {Binding -XPath title} 
        }
    }
}


show-ui -Xaml @"
<ListBox ItemsSource="{Binding}" MinWidth="200" MinHeight="150" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <ListBox.DataContext>
        <XmlDataProvider Source="http://search.twitter.com/search.rss?q=powershell" XPath="/rss/channel/item"/>
    </ListBox.DataContext>
    <ListBox.ItemTemplate>
        <DataTemplate>
            <Label Content="{Binding XPath=title}" />
        </DataTemplate>
    </ListBox.ItemTemplate>
</ListBox>
"@


Show-UI -Xaml @'
 <DockPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <DockPanel.DataContext>
        <XmlDataProvider Source="http://www.thomasclaudiushuber.com/blog/feed/" XPath="/rss/channel/item"/>
    </DockPanel.DataContext>   
  <StackPanel DockPanel.Dock="Top" TextElement.FontWeight="Bold" Background="LightGray">
   <TextBlock Text="{Binding XPath=./../title}" FontSize="20" Margin="10 10 10 0"/>
    <TextBlock Text="{Binding XPath=./../description}" FontSize="10" FontWeight="Normal" Margin="10 0"/>
   <TextBox Margin="5" Text="{Binding BindsDirectlyToSource=True, Path=Source, UpdateSourceTrigger=PropertyChanged}"/>
 </StackPanel>

  <StatusBar DockPanel.Dock="Bottom">
   <StatusBarItem Content="{Binding XPath=title}"/>
   <Separator/>
   <StatusBarItem Content="{Binding XPath=pubDate}"/>
  </StatusBar>

  <Grid>
   <Grid.ColumnDefinitions>
    <ColumnDefinition Width="308"/>
    <ColumnDefinition Width="400*"/>
   </Grid.ColumnDefinitions>

   <GroupBox Header="Blog-Eintr?ge">
    <ListBox IsSynchronizedWithCurrentItem="True" ItemsSource="{Binding}" DisplayMemberPath="title"/>
   </GroupBox>
   <GridSplitter Grid.Column="1" HorizontalAlignment="Left" Width="10"/>
   <Frame Margin="10,0,0,0" Grid.Column="1" Source="{Binding XPath=link}" MaxWidth="1024"/>
  </Grid>

 </DockPanel>
'@
