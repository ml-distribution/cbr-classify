package zx.soft.cbr.classify.utils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Collection;
import java.util.Date;

/**
 * 
 * @author wanggang
 *
 */
@SuppressWarnings("rawtypes")
public class Accessor {

	private Object owner;

	private Class ownerClass;

	private Method getter;

	private Method setter;

	/**
	 * @param ownerClass
	 *            Classe de onde foram capturados os m�todos
	 * @param getter
	 *            M�todo get do atributo
	 * @param setter
	 *            M�todo set do atributo
	 */
	public Accessor(Class ownerClass, Method getter, Method setter) {
		setOwnerClass(ownerClass);
		setGetter(getter);
		setSetter(setter);
	}

	/**
	 * @param owner
	 *            Objeto de onde foram capturados os m�todos
	 * @param getter
	 *            M�todo get do atributo
	 * @param setter
	 *            M�todo set do atributo
	 */
	public Accessor(Object owner, Method getter, Method setter) {
		setOwner(owner);
		setGetter(getter);
		setSetter(setter);
	}

	/**
	 * Construtor que j� atribui valor a todos os atributos
	 * 
	 * @param owner
	 *            Objeto de onde foram capturados os m�todos
	 * @param ownerClass
	 *            Classe de onde foram capturados os m�todos
	 * @param getter
	 *            M�todo get do atributo
	 * @param setter
	 *            M�todo set do atributo
	 */
	public Accessor(Object owner, Class ownerClass, Method getter, Method setter) {
		setOwner(owner);
		if (owner == null) {
			setOwnerClass(ownerClass); // caso null pois o setOwner j� faz isso
		}
		setGetter(getter);
		setSetter(setter);
	}

	/**
	 * Retorna o objeto dono do atributo
	 * 
	 * @return owner
	 */
	public Object getOwner() {
		return owner;
	}

	/**
	 * Atribui um dono ao atributo
	 * 
	 * @param owner
	 */
	public void setOwner(Object owner) {
		if (owner != null) {
			// se n�o houver uma classe definida ou se o dono for uma inst�ncia
			// da
			// classe...
			if (getOwnerClass() == null || ReflectionUtil.isInstance(owner, getOwnerClass())) {
				this.owner = owner;
			} else {
				throw new IncompatibleClassException("Objeto incompat�vel com classe definidinida");
			}
			// se a classe do dono ainda n�o tiver sido definida
			if (getOwnerClass() == null && owner != null) {
				setOwnerClass(owner.getClass());
			}
		} else {
			this.owner = owner;
		}
	}

	/**
	 * Retorna a classe de onde o atributo foi capturado
	 * 
	 * @return ownerClass
	 */
	public Class getOwnerClass() {
		return ownerClass;
	}

	/**
	 * Atribui uma classe de origem para esse atributo
	 * 
	 * @param ownerClass
	 */
	public void setOwnerClass(Class ownerClass) {
		if (ownerClass != null) {
			if (getGetter() != null && !getGetter().getDeclaringClass().equals(ownerClass)
					&& !ReflectionUtil.getAllSuperclasses(ownerClass).contains(getGetter().getDeclaringClass())) {
				throw new IncompatibleClassException("Classe incompat�vel com m�todo get");
			}
			if (getSetter() != null && !getSetter().getDeclaringClass().equals(ownerClass)
					&& !ReflectionUtil.getAllSuperclasses(ownerClass).contains(getSetter().getDeclaringClass())) {
				throw new IncompatibleClassException("Classe incompat�vel com m�todo set");
			}
			// se n�o houver um objeto dono do atributo ou se o dono for uma
			// inst�ncia da classe recebida...
			if (getOwner() == null || ReflectionUtil.isInstance(getOwner(), ownerClass)) {
				this.ownerClass = ownerClass;
			} else {
				throw new IncompatibleClassException("Classe incompat�vel com o dono definidinido");
			}
		} else {
			this.ownerClass = ownerClass;
		}
	}

	/**
	 * Retorna o m�todo get do atributo
	 * 
	 * @return getter
	 */
	public Method getGetter() {
		return getter;
	}

	/**
	 * Atribui um m�todo get ao atributo
	 * 
	 * @param getter
	 */
	public void setGetter(Method getter) {
		if (getter != null) {
			// se for um getter
			if (AccessorUtil.isGetter(getter)) {
				// e se n�o houver setter ou se o setter existente for do mesmo
				// atributo e tipo do getter recebido...
				if (AccessorUtil.isCompatible(getter, getSetter())) {
					this.getter = getter;
				} else {
					throw new IncompatibleMethodException(
							"O getter fornecido n�o corresponde ao atributo do setter existente. Getter:" + getter
									+ " - Setter: " + getSetter());
				}
			} else {
				throw new InvalidAccessorException("O m�todo fornecido n�o � um getter");
			}
		} else {
			this.getter = getter;
		}
	}

	/**
	 * Retorna o m�todo set do atributo
	 * 
	 * @return setter
	 */
	public Method getSetter() {
		return setter;
	}

	/**
	 * Atribui um m�todo set ao atributo
	 * 
	 * @param setter
	 */
	public void setSetter(Method setter) {
		if (setter != null) {
			// se for um setter
			if (AccessorUtil.isSetter(setter)) {
				// e se n�o houver getter ou se o getter existente for do mesmo
				// atributo e tipo do setter recebido...
				if (AccessorUtil.isCompatible(getGetter(), setter)) {
					this.setter = setter;
				} else {
					throw new IncompatibleMethodException(
							"O setter fornecido n�o corresponde ao atributo do getter existente. Getter:" + getter
									+ " - Setter: " + getSetter());
				}
			} else {
				throw new InvalidAccessorException("O m�todo fornecido n�o � um setter");
			}
		} else {
			this.setter = setter;
		}
	}

	/**
	 * Retorna o nome do atributo com base no m�todo de acesso dispon�vel
	 * 
	 * @return name
	 */
	public String getName() {
		String name = null;
		if (getSetter() != null) {
			name = AccessorUtil.getAttributeName(getSetter());
		} else if (getGetter() != null) {
			name = AccessorUtil.getAttributeName(getGetter());
		}
		return name;
	}

	/**
	 * Verifica se o valor do atributo pode ser recuperado, ou seja, se ele possui um m�todo get correspondente
	 * 
	 * @return true se houver um getter
	 */
	public boolean isReadable() {
		return getGetter() != null;
	}

	/**
	 * Verifica se o valor do atributo pode ser modificado, ou seja, se ele possui um m�todo set correspondente
	 * 
	 * @return true se houver um setter
	 */
	public boolean isWriteable() {
		return getSetter() != null;
	}

	/**
	 * Verifica se o valor do atributo pode ser recuperado e modificado (leitura e escrita)
	 * 
	 * @return true se houver getter e setter
	 */
	public boolean isRW() {
		return isReadable() && isWriteable();
	}

	/**
	 * Verifica se o valor do atributo pode ser apenas recuperado (apenas leitura)
	 * 
	 * @return true se houver getter mas n�o houver setter
	 */
	public boolean isRO() {
		return isReadable() && !isWriteable();
	}

	/**
	 * Invoca o m�todo get no objeto fornecido para recuperar o valor de seu atributo
	 * 
	 * @param obj
	 *            Objeto de onde o valor do atributo ser� recuperado
	 * @return retorno do getter
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public Object invokeGetter(Object obj) throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		return getGetter().invoke(obj, (Object[]) null);
	}

	/**
	 * Invoca o m�todo set no objeto para modificar o valor de seu atributo com os par�metros fornecidos
	 * 
	 * @param obj
	 *            Objeto no qual o valor do atributo ser� modificado
	 * @param param
	 *            Novo valor do atributo
	 * @return retorno do setter
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public Object invokeSetter(Object obj, Object param) throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		if (ReflectionUtil.isCompatible(param, getType())) {
			return getSetter().invoke(obj, new Object[] { param });
		}
		Object value = AccessorUtil.convert(param, getType());
		return getSetter().invoke(obj, new Object[] { value });

	}

	/**
	 * Invoca o m�todo get no objeto dono para recuperar o valor de seu atributo
	 * 
	 * @return retorno do getter
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public Object invokeGetterOnOwner() throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		return invokeGetter(getOwner());
	}

	/**
	 * Invoca o m�todo set no objeto dono para modificar o valor de seu atributo com os par�metros fornecidos
	 * 
	 * @param param
	 *            Novo valor do atributo
	 * @return retorno do setter
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public Object invokeSetterOnOwner(Object param) throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		return invokeSetter(getOwner(), param);
	}

	/**
	 * Retorna a classe do atributo representado pelo objeto
	 * 
	 * @return tipo do atributo
	 */
	public Class getType() {
		if (getGetter() != null)
			return getGetter().getReturnType();
		else if (getSetter() != null)
			return getSetter().getParameterTypes()[0];
		else
			throw new NullPointerException("N�o h� informa��o para identificar a classe do atributo");
	}

	/**
	 * Determina se a classe especificada do objeto <br>
	 * � de tipo primitivo ou de tipo Java. <br> - Suporta verificac�o para tipos primitivos do tipo:<br>
	 * boolean, byte, char, short, int, long, float, and double <br> - Suporta verificac�o para tipos Java do tipo:<br>
	 * Boolean, Byte, Character, Short, Stirng, Integer, Long, Float, Double and Date <br>
	 * 
	 * @return true se for um tipo do java
	 */
	public boolean isJavaType() {
		Class type = this.getType();
		if (type.isPrimitive())
			return true;

		if (type.equals(Boolean.class) || type.equals(Byte.class) || type.equals(Character.class)
				|| type.equals(Short.class) || type.equals(String.class) || type.equals(Integer.class)
				|| type.equals(Long.class) || type.equals(Float.class) || type.equals(Double.class)
				|| type.equals(Date.class))
			return true;

		return false;
	}

	/**
	 * Reseta o objeto
	 */
	public void reset() {
		getter = null;
		setter = null;
		owner = null;
		ownerClass = null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(Object obj) {
		return equals((Accessor) obj);
	}

	/**
	 * Compara dois objetos Accessor. S�o iguais se os atributos owner, ownerClass, getter e setter forem iguais
	 * 
	 * @param obj
	 * @return true se os accessors forem iguais
	 */
	public boolean equals(Accessor obj) {
		return ObjectUtil.equals(new Object[][] { { getOwner(), obj.getOwner() },
				{ getOwnerClass(), obj.getOwnerClass() }, { getGetter(), obj.getGetter() },
				{ getSetter(), obj.getSetter() } });
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Object#toString()
	 */
	@Override
	public String toString() {
		return getName() + "[" + (getGetter() != null ? "get" : "")
				+ (getGetter() != null && getSetter() != null ? ", " : "") + (getSetter() != null ? "set" : "") + "]";
	}

	/**
	 * @param value
	 * @throws InstantiationException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 * @throws InstantiationException
	 * 
	 */
	public void setOrAddToAttribute(Object value) throws InstantiationException, IllegalAccessException,
			InvocationTargetException, InstantiationException {
		setOrAddToAttribute(this, getOwner(), value);
	}

	/**
	 * @param entity
	 * @param value
	 * @throws InstantiationException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 * @throws InstantiationException
	 * 
	 */
	public void setOrAddToAttribute(Object entity, Object value) throws InstantiationException, IllegalAccessException,
			InvocationTargetException, InstantiationException {
		setOrAddToAttribute(this, entity, value);
	}

	/**
	 * @param ac
	 * @param entity
	 * @param value
	 * @throws InstantiationException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 * @throws InstantiationException
	 * 
	 */
	@SuppressWarnings("unchecked")
	public static void setOrAddToAttribute(Accessor ac, Object entity, Object value) throws InstantiationException,
			IllegalAccessException, InvocationTargetException, InstantiationException {
		if (ac != null) {
			if (!ReflectionUtil.isImplementedByAny(Collection.class, ac.getType())) {
				ac.invokeSetter(entity, value);
			} else {
				if (ac.invokeGetter(entity) == null) {
					ac.invokeSetter(entity, AccessorUtil.newInstance(ac.getType()));
				}
				if (ReflectionUtil.isImplementedByAny(Collection.class, value.getClass())) {
					((Collection) ac.invokeGetter(entity)).addAll((Collection) value);
				} else {
					((Collection) ac.invokeGetter(entity)).add(value);
				}
			}
		}
	}

	public Object newInstance() throws InstantiationException, IllegalAccessException {
		return AccessorUtil.newInstance(this.getType());
	}

	public boolean isCollection() {
		return ReflectionUtil.isCollection(getType());
	}

	public void copy(Object orign, Object dest) throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		invokeSetter(dest, invokeGetter(orign));
	}

}
