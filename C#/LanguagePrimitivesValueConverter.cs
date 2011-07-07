namespace ShowUI
{
    using System;
    using System.Windows;
    using System.Windows.Data;
    using System.Management.Automation;   
    using System.Globalization;

    public class LanguagePrimitivesValueConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            return LanguagePrimitives.ConvertTo(value, targetType);
        }
        
        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) 
        {
            return LanguagePrimitives.ConvertTo(value, targetType);
        }
    }
}
