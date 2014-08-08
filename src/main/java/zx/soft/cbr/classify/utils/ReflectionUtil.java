package zx.soft.cbr.classify.utils;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SuppressWarnings({ "null", "rawtypes" })
public class ReflectionUtil {

	/**
	 * Verifica se a interface implementada pela classe ou mesmo por alguma de suas generalizaes at Object <br>
	 * Tem praticamente o resultado de clazz.isAssignableFrom, porem levando em considerao apenas as interfaces...
	 * 
	 * @param iface
	 *            Interface a ser procurada na classe ou em suas generalizaes
	 * @param clazz
	 *            Classe a ser verificada
	 * @return True se a classe ou alguma de suas generalizaes at Object implementa a interface
	 */
	public static boolean isImplementedByAny(Class<?> iface, Class<?> clazz) {
		boolean result = false;
		if (clazz != null || !clazz.isPrimitive()) {
			List<?> allInterfaces = getAllInterfaces(clazz);
			return allInterfaces.contains(iface);
		}
		return result;
	}

	public static boolean isCollection(Class<?> clazz) {
		return isImplementedByAny(Collection.class, clazz);
	}

	/**
	 * Retorna todas as generalizaes at Object
	 * 
	 * @param clazz
	 *            Classe de onde sero capturadas as generalizaes
	 * @return generalizacoes
	 */
	public static List<Class> getAllSuperclasses(Class<?> clazz) {
		return getAllSuperclasses(clazz, Object.class);
	}

	/**
	 * Retorna todas as generalizaes at Object ou at a classe limite
	 * 
	 * @param clazz
	 *            Classe de onde sero capturadas as generalizaes
	 * @param limitClazz
	 *            Classe limite na busca por generalizaes
	 * @return generalizacoes
	 */
	public static List<Class> getAllSuperclasses(Class<?> clazz, Class<?> limitClazz) {
		List<Class> supers = new ArrayList<Class>();
		if (clazz != null && !clazz.equals(Object.class)) {
			Class ultima = clazz;
			while (ultima != null && !ultima.equals(Object.class)
					&& (limitClazz == null || !ultima.equals(limitClazz.getClass()))) {
				ultima = ultima.getSuperclass();
				if (ultima != null) {
					supers.add(ultima);
				}
			}
		} else if (clazz != null && clazz.equals(Object.class)) {
			supers.add(Object.class);
		}
		return supers;
	}

	/**
	 * Verifica se a interface  implementada pela classe ou mesmo por alguma de suas generalizaes at Object. Mtodo criado para os casos onde se tem um Object e no se sabe a classe para fazer um
	 * instanceof NomeClasse, possibilitando teste similar ao instanceof entre um objeto qualquer e um objeto Class
	 * 
	 * @param obj
	 *            Objeto a ser verificado
	 * @param clazz
	 *            Classe ou generalizao do qual o objeto deve ser instancia
	 * @return true se for instancia da classe
	 */
	public static boolean isInstance(Object obj, Class<?> clazz) {
		boolean result = obj.getClass().equals(clazz);
		if (!result) {
			result = getAllSuperclasses(obj.getClass(), clazz).contains(clazz);
		}
		return result;
	}

	/**
	 * Verifica se alguma das interfaces  implementada pela classe ou mesmo por alguma de suas generalizaes at Object
	 * 
	 * @param ifaces
	 *            Interfaces a serem procurada na classe ou em suas generalizaes
	 * @param clazz
	 *            Classe a ser verificada
	 * @return True se a classe ou alguma de suas generalizaes at Object implementa a interface
	 */
	public static boolean isImplementedByAny(Class[] ifaces, Class<?> clazz) {
		for (int i = 0; i < ifaces.length; i++) {
			if (!isImplementedByAny(ifaces[i], clazz)) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Retorna todas as interfaces implementadas pela classe e generalizaes
	 * 
	 * @param clazz
	 *            Classe a partir de onde sero extraidas as classes
	 * @return Interfaces implementadas pela classe e suas generalizaes at Object
	 */
	public static List<Class> getAllInterfaces(Class clazz) {
		List<Class> interfaces = new ArrayList<Class>();
		while (clazz != null && !clazz.equals(Object.class)) {
			for (int i = 0; i < clazz.getInterfaces().length; i++) {
				Class iface = clazz.getInterfaces()[i];
				interfaces.add(iface);
				interfaces.addAll(getAllSuperclasses(iface));
			}
			clazz = clazz.getSuperclass();
		}
		return interfaces;
	}

	public static boolean isCompatible(Object obj, Class clazz) {
		return isCompatible(obj.getClass(), clazz);
	}

	public static boolean isCompatible(Class<? extends Object> objectClass, Class clazz) {
		if (clazz.isInterface()) {
			return isImplementedByAny(clazz, objectClass);
		}
		return getAllSuperclasses(clazz, objectClass).contains(objectClass);
	}

	public static Map<String, Object> getValueMap(Object obj) throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		Map<String, Object> result = new HashMap<String, Object>();
		List<Accessor> accs = AccessorUtil.getAccessorsList(obj);
		for (Accessor accessor : accs) {
			result.put(accessor.getName(), accessor.invokeGetter(obj));
		}
		return result;
	}

}
