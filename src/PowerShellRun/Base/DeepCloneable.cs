using System;
using System.Reflection;

namespace PowerShellRun;

public abstract class DeepCloneable
{
    protected abstract object EmptyNew();

    static internal object? DeepClone(object? obj)
    {
        if (obj is null)
            return null;

        var type = obj.GetType();

        if (type.IsValueType || type == typeof(string))
        {
            return obj;
        }
        else
        if (type.IsArray)
        {
            if (type.FullName is null)
                return null;

            var elementType = Type.GetType(type.FullName.Replace("[]", ""));
            if (elementType is null)
                return null;

            Array srcArray = (obj as Array)!;
            var newArray = Array.CreateInstance(elementType, srcArray.Length);
            for (int i = 0; i < srcArray.Length; ++i)
            {
                newArray.SetValue(DeepClone(srcArray.GetValue(i)), i);
            }
            return Convert.ChangeType(newArray, type);
        }
        else
        if (type.IsClass)
        {
            object? newObj = null;
            if (obj is DeepCloneable)
            {
                newObj = ((DeepCloneable)obj).EmptyNew();
            }
            else
            {
                newObj = Activator.CreateInstance(type);
            }
            var fields = type.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.FlattenHierarchy);
            foreach (var field in fields)
            {
                var fieldValue = field.GetValue(obj);
                field.SetValue(newObj, DeepClone(fieldValue));
            }
            return newObj;
        }
        return null;
    }
}
