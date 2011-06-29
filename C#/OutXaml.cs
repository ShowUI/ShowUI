namespace ShowUI
{

using System;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Management.Automation;
using System.Windows;
using System.Windows.Data;
using System.Windows.Markup;


   public class BindingTypeDescriptionProvider : TypeDescriptionProvider
   {
      private static readonly TypeDescriptionProvider DefaultTypeProvider = TypeDescriptor.GetProvider(typeof(Binding));

      public BindingTypeDescriptionProvider() : base(DefaultTypeProvider) { }

      public override ICustomTypeDescriptor GetTypeDescriptor(Type objectType, object instance)
      {
         ICustomTypeDescriptor defaultDescriptor = base.GetTypeDescriptor(objectType, instance);
         return instance == null ? defaultDescriptor : new BindingCustomTypeDescriptor(defaultDescriptor);
      }
   }

   public class BindingCustomTypeDescriptor : CustomTypeDescriptor
   {
      public BindingCustomTypeDescriptor(ICustomTypeDescriptor parent) : base(parent) { }

      public override PropertyDescriptorCollection GetProperties(Attribute[] attributes)
      {
         PropertyDescriptor pd;
         var pdc = new PropertyDescriptorCollection(base.GetProperties(attributes).Cast<PropertyDescriptor>().ToArray());
         if ((pd = pdc.Find("Source", false)) != null)
         {
            pdc.Add(TypeDescriptor.CreateProperty(typeof(Binding), pd, new Attribute[] { new DefaultValueAttribute("null") }));
            pdc.Remove(pd);
         }
         return pdc;
      }
   }

   public class BindingConverter : ExpressionConverter
   {
      public override bool CanConvertTo(ITypeDescriptorContext context, Type destinationType)
      {
         return (destinationType == typeof(MarkupExtension)) ? true : false;
      }
      public override object ConvertTo(ITypeDescriptorContext context, CultureInfo culture, object value, Type destinationType)
      {
         if (destinationType == typeof(MarkupExtension))
         {
            var bindingExpression = value as BindingExpression;
            if (bindingExpression == null) throw new Exception();
            return bindingExpression.ParentBinding;
         }

         return base.ConvertTo(context, culture, value, destinationType);
      }
   }

   [Cmdlet(VerbsData.Out, "Xaml", SupportsShouldProcess = false, ConfirmImpact = ConfirmImpact.None, DefaultParameterSetName = "DataTemplate")]
   public class OutXaml : Cmdlet
   {
      static OutXaml()
      {
         // this is absolutely vital:
         TypeDescriptor.AddProvider(new BindingTypeDescriptionProvider(), typeof(Binding));
         TypeDescriptor.AddAttributes(typeof(BindingExpression), new Attribute[] { new TypeConverterAttribute(typeof(BindingConverter)) });
      }

      [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true)]
      public PSObject InputObject { get; set; }

      protected override void ProcessRecord() {
         WriteObject(XamlWriter.Save(InputObject.BaseObject));
      }

   }
}
