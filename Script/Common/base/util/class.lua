-- Create an class.

function clone(object)--clone����  
    local lookup_table = {}--�½�table���ڼ�¼  
    local function _copy(object)--_copy(object)��������ʵ�ָ���  
        if type(object) ~= "table" then   
            return object   ---������ݲ���table ֱ�ӷ���object(�������������\�ַ���ֱ�ӷ��ظ�����\���ַ���)  
        elseif lookup_table[object] then  
            return lookup_table[object]--���������ڵݹ��ʱ���,������table�Ѿ����ƹ���,��ֱ�ӷ���  
        end  
        local new_table = {}  
        lookup_table[object] = new_table--�½�new_table��¼��Ҫ���ƵĶ����ӱ�,���ŵ�lookup_table[object]��.  
        for key, value in pairs(object) do  
            new_table[_copy(key)] = _copy(value)--����object�͵ݹ�_copy(value)��ÿһ�����е����ݶ����Ƴ���  
        end  
        return setmetatable(new_table, getmetatable(object))--ÿһ����ɱ�����,�Ͷ�ָ��table����metatable��ֵ  
    end  
    return _copy(object)--����clone������object��ָ��/��ַ  
end   

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end

        cls.ctor    = function() end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end