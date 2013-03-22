namespace ShowUI
{
    using System;
    using System.Windows;
    using System.Windows.Media;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Linq;
    using System.Management.Automation;
    using System.Windows.Controls;

    
    public class ShowUISetting : DependencyObject
    {
        public static readonly DependencyProperty ControlNameProperty = DependencyProperty.RegisterAttached(
            "ControlName",
            typeof(string),
            typeof(ShowUISetting),
            new FrameworkPropertyMetadata());
        
        public static void SetControlName(UIElement element, string value)
        {
            element.SetValue(ControlNameProperty, value);
        }
        
        public static string GetControlName(UIElement element)
        {
            return (string)element.GetValue(ControlNameProperty);
        }

        public static readonly DependencyProperty StyleNameProperty = DependencyProperty.RegisterAttached(
            "StyleName",
            typeof(string),
            typeof(ShowUISetting),
            new FrameworkPropertyMetadata());

        public static void SetStylelName(UIElement element, string value)
        {
            element.SetValue(StyleNameProperty, value);
        }

        public static string GetStylelName(UIElement element)
        {
            return (string)element.GetValue(StyleNameProperty);
        }                       
    }

    public static class ShowUIExtensions
    {
        public static IEnumerable<DependencyObject> GetChildControl(this DependencyObject control,
                bool peekIntoNestedControl,
                Type[] byType,
                string[] byControlName,
                string[] byName,
                bool onlyDirectChildren)
        {
            bool hasEnumeratedChildren = false;
            Queue<DependencyObject> queue = new Queue<DependencyObject>();
            queue.Enqueue(control);
            while (queue.Count > 0)
            {
                DependencyObject parent = queue.Peek();
                string controlName = (string)parent.GetValue(ShowUI.ShowUISetting.ControlNameProperty);
                string name = String.Empty;
                if ((parent is FrameworkElement))
                {
                    name = (parent as FrameworkElement).Name;
                }

                if (byName != null && (!String.IsNullOrEmpty(name)))
                {
                    foreach (string n in byName)
                    {
                        if (String.Compare(n, name, true) == 0)
                        {
                            yield return parent;
                        }
                    }
                }
                else if (byControlName != null && (!String.IsNullOrEmpty(controlName)))
                {
                    foreach (string n in byControlName)
                    {
                        if (String.Compare(n, controlName, true) == 0)
                        {
                            yield return parent;
                        }
                    }
                }
                else if (byType != null)
                {
                    foreach (Type t in byType)
                    {
                        Type parentType = parent.GetType();
                        if (t.IsInterface && parentType.GetInterface(t.FullName) != null)
                        {
                            yield return parent;
                        }
                    }
                }
                else
                {
                    yield return parent;
                }

                int childCount = VisualTreeHelper.GetChildrenCount(parent);
                if (childCount > 0)
                {
                    if (!(hasEnumeratedChildren && onlyDirectChildren))
                    {
                        if ((!hasEnumeratedChildren) ||
                            ((String.IsNullOrEmpty(controlName) || peekIntoNestedControl)))
                        {
                            hasEnumeratedChildren = true;
                            for (int i = 0; i < childCount; i++)
                            {
                                DependencyObject child = VisualTreeHelper.GetChild(parent, i);
                                queue.Enqueue(child);
                            }
                        }
                    }
                }
                else
                {
                    if (parent is ContentControl)
                    {
                        object childObject = (parent as ContentControl).Content;
                        if (childObject != null && childObject is Visual)
                        {
                            queue.Enqueue(childObject as Visual);
                        }
                    }
                }

                queue.Dequeue();
            }

        }
    }
}
