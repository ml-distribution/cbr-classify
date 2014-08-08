package zx.soft.cbr.classify.utils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;

/**
 * 
 * @author wanggang
 *
 */
@SuppressWarnings({ "rawtypes", "unchecked" })
public class AccessorUtil {

	/**
	 * Map de maps de accessors com a classe como chave, para armazenar maps j montados.
	 */
	private static Map<Class, Map<String, Accessor>> accessorMapCache = new HashMap<Class, Map<String, Accessor>>();

	/**
	 * Retorna um objeto Accessor representando um atributo especfico
	 * 
	 * @param name
	 *            Nome do atributo a ser procurado
	 * @param clazz
	 *            Classe a ser analisada
	 * @return accessor do atributo especificado
	 */
	public static Accessor getAccessor(String name, Class clazz) {
		Accessor ac = getAccessorsMap(clazz).get(name);
		// logger.debug("Accessor procurado para o atributo: " + name + " na
		// classe " + clazz.getName().substring(clazz.getName().lastIndexOf(".")
		// + 1) + " - Encontrado: " + ac);
		return ac;
	}

	/**
	 * Retorna um objeto Accessor representando um atributo especfico
	 * 
	 * @param names
	 *            Nomes separados por vrgula dos atributos a serem procurados
	 * @param clazz
	 *            Classe a ser analisada
	 * @return lista com os accessors dos atributos especificados
	 */
	public static Collection<Accessor> getAccessors(String names, Class clazz) {
		Collection<Accessor> acs = new ArrayList<Accessor>();
		StringTokenizer st = new StringTokenizer(names, ",");
		while (st.hasMoreTokens()) {
			acs.add(getAccessor(st.nextToken().trim(), clazz));
		}
		if (!acs.isEmpty())
			return acs;
		return null;
	}

	/**
	 * Retorna um objeto Accessor representando um atributo especfico
	 * 
	 * @param name
	 *            Nome do atributo a ser procurado
	 * @param obj
	 *            Objeto a ser analisado
	 * @return accessor
	 */
	public static Accessor getAccessor(String name, Object obj) {
		Accessor attribute = getAccessor(name, obj.getClass());
		if (attribute != null) {
			attribute.setOwner(obj);
		}
		return attribute;
	}

	/**
	 * Analisa uma classe retornando um Map de objetos Accessor com o nome do mesmo como chave. Suporta apenas um get (ou is) e/ou um set para cada atributo
	 * 
	 * @param clazz
	 *            Classe a ser analisada
	 * @return map
	 */
	public static Map<String, Accessor> getAccessorsMap(Class clazz) {
		return getAccessorsMap(clazz, null, true);
	}

	/**
	 * Analisa uma classe retornando um Map de objetos Accessor com o nome do mesmo como chave. Suporta apenas um get (ou is) e/ou um set para cada atributo
	 * 
	 * @param obj
	 *            Objeto a ser analisado
	 * @return map
	 */
	public static Map<String, Accessor> getAccessorsMap(Object obj) {
		return getAccessorsMap(obj.getClass(), obj, true);
	}

	/**
	 * Analisa uma classe retornando um Map de objetos Accessor com o nome do mesmo como chave e como objeto obj como owner de cada accessor. Suporta apenas um get (ou is) e/ou um set para cada
	 * atributo
	 * 
	 * @param clazz
	 *            Classe a ser analisada
	 * @param obj
	 *            Objeto dono dos accessors
	 * @param updateOwner
	 * @return map
	 */
	public static Map<String, Accessor> getAccessorsMap(Class clazz, Object obj, boolean updateOwner) {
		Map<String, Accessor> result = accessorMapCache.get(clazz);
		if (result == null) {
			result = new HashMap<String, Accessor>();
			for (int i = 0; i < clazz.getMethods().length; i++) {
				Method method = clazz.getMethods()[i];
				if (isAccessor(method)) {
					String name = getAttributeName(method);
					Accessor attribute = result.get(name);
					if (attribute == null) {
						if (isGetter(method)) {
							attribute = new Accessor(obj, clazz, method, null);
						} else {
							attribute = new Accessor(obj, clazz, null, method);
						}
						result.put(name, attribute);
					} else {
						if (isGetter(method) && isCompatible(method, attribute.getSetter())) {
							attribute.setGetter(method);
						} else if (isCompatible(attribute.getGetter(), method)) {
							attribute.setSetter(method);
						}
					}
				}
			}
			accessorMapCache.put(clazz, result);
			// logger.debug("Map de accessors adicionada  cache: " + result + "
			// na classe " +
			// clazz.getName().substring(clazz.getName().lastIndexOf(".") + 1));
		} else {
			// logger.debug("Map de accessors recuperada da cache: " + result +
			// " na classe " +
			// clazz.getName().substring(clazz.getName().lastIndexOf(".") + 1));
			if (updateOwner) {
				for (Iterator<Accessor> i = result.values().iterator(); i.hasNext();) {
					Accessor ac = i.next();
					if (obj == null || !ObjectUtil.equals(ac.getOwner(), obj)) {
						ac.setOwner(obj);
					}
				}
				// logger.debug("Owner dos accessors atualizados: " + result + "
				// na classe " +
				// clazz.getName().substring(clazz.getName().lastIndexOf(".") +
				// 1));
			}
		}
		return result;
	}

	/**
	 * Analisa uma classe retornando um List de objetos Accessor. Suporta apenas um get (ou is) e/ou um set para cada atributo
	 * 
	 * @param clazz
	 *            Classe a ser analisada
	 * @return list
	 */
	public static List<Accessor> getAccessorsList(Class clazz) {
		List<Accessor> result = new ArrayList<Accessor>();
		result.addAll(getAccessorsMap(clazz).values());
		return result;
	}

	/**
	 * Analisa um objeto retornando um List de objetos Accessor. Suporta apenas um get (ou is) e/ou um set para cada atributo
	 * 
	 * @param obj
	 *            Objeto dono dos accessors
	 * @return list
	 */
	public static List<Accessor> getAccessorsList(Object obj) {
		List<Accessor> result = new ArrayList<Accessor>();
		result.addAll(getAccessorsMap(obj).values());
		return result;
	}

	/**
	 * Retorna o nome de todos os atributos de uma classe
	 * 
	 * @param clazz
	 *            Classe a ser analisada
	 * @return names
	 */
	public static String[] getAllAttributesName(Class clazz) {
		String[] result = null;
		Set nomes = getAccessorsMap(clazz).keySet();
		if (!nomes.isEmpty()) {
			result = new String[nomes.size()];
			int j = 0;
			for (Iterator i = nomes.iterator(); i.hasNext();) {
				result[j] = (String) (i.next());
				j++;
			}
		}
		return result;
	}

	/**
	 * Retorna o nome de todos os atributos das classes contidas na coleo
	 * 
	 * @param classes
	 *            Classes a serem analisadas
	 * @return names
	 */
	public static String[] getAllAttributesName(Collection classes) {
		String[] result = null;
		int resultLength = 0;
		Object[] names = new Object[classes.size()];
		int j = 0;
		for (Iterator i = classes.iterator(); i.hasNext();) {
			Class clazz = (Class) i.next();
			names[j] = getAllAttributesName(clazz);
			if (names[j] != null) {
				resultLength += ((String[]) names[j]).length;
			}
			j++;
		}
		if (resultLength > 0) {
			result = new String[resultLength];
			int i = 0;
			for (j = 0; j < names.length; j++) {
				if (names[j] != null) {
					for (int k = 0; k < ((String[]) names[j]).length; k++) {
						result[i] = ((String[]) names[j])[k];
						i++;
					}
				}
			}
		}
		return result;
	}

	/**
	 * Retorna o nome do atributo caso o mtodo seja um mtodo de acesso retornando null caso contrrio
	 * 
	 * @param method
	 *            Possvel mtodo de acesso
	 * @return name
	 */
	public static String getAttributeName(Method method) {
		String name = null;
		if (isAccessor(method)) {
			if (method.getName().startsWith("set") || method.getName().startsWith("get")) {
				name = method.getName().substring(3);
			} else if (method.getName().startsWith("is")) {
				name = method.getName().substring(2);
			}
		}

		return name.equals("") ? "" : name.substring(0, 1).toLowerCase() + name.substring(1);
	}

	/**
	 * Verifica se o mtodo  um get
	 * 
	 * @param method
	 *            Mtodo a ser verificado
	 * @return true se for um getter
	 */
	public static boolean isGetter(Method method) {
		return (method.getName().startsWith("get") || method.getName().startsWith("is"))
				&& method.getReturnType() != null
				&& (method.getParameterTypes() == null || method.getParameterTypes().length == 0);
	}

	/**
	 * Verifica se o mtodo  um set
	 * 
	 * @param method
	 *            Mtodo a ser verificado
	 * @return true se for um setter
	 */
	public static boolean isSetter(Method method) {
		return method.getName().startsWith("set")
				&& (method.getParameterTypes() != null || method.getParameterTypes().length == 1);
	}

	/**
	 * Verifica se o mtodo  um mtodo de acesso
	 * 
	 * @param method
	 *            Mtodo a ser verificado
	 * @return true se for um accessor
	 */
	public static boolean isAccessor(Method method) {
		return isGetter(method) || isSetter(method);
	}

	/**
	 * Map com interfaces ou classes abstratas como chaves e classes concretas correspondentes como valor
	 */
	private static Map<Class, Class> typeMap = new HashMap<Class, Class>();

	public static void putType(Class abstraction, Class concrete) {
		typeMap.put(abstraction, concrete);
	}

	public static Class getConcrete(Class abstraction) {
		return typeMap.get(abstraction);
	}

	static {
		putType(List.class, ArrayList.class);
		putType(Map.class, HashMap.class);
		putType(Set.class, HashSet.class);
	}

	/**
	 * @param type
	 * @return instance
	 * @throws IllegalAccessException
	 * @throws InstantiationException
	 */
	public static Object newInstance(Class type) throws InstantiationException, IllegalAccessException {
		Class concrete = getConcrete(type);
		if (concrete != null) {
			return concrete.newInstance();
		}
		return type.newInstance();
	}

	/**
	 * Transfere o contedo da entidade origem para a entidade destino, mesmo que os objetos sejam de classes diferentes (atributos que tiverem o mesmo nome e mesmo tipo sero copiados)
	 * 
	 * @param orign
	 * @param dest
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public static void copy(Object orign, Object dest) throws IllegalArgumentException, IllegalAccessException,
			InvocationTargetException {
		copy(COPY_EXCEPT, "", orign, dest);
	}

	/**
	 * Transfere o contedo da entidade origem para a entidade destino com recursividade, mesmo que os objetos sejam de classes diferentes (atributos que tiverem o mesmo nome e mesmo tipo sero
	 * copiados)
	 * 
	 * @param orign
	 * @param dest
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public static void copyRecursive(Object orign, Object dest) throws IllegalArgumentException,
			IllegalAccessException, InvocationTargetException {
		copyRecursive(COPY_EXCEPT, "", orign, dest);
	}

	/**
	 * No copia os elementos ignorados, <br>
	 * por exemplo objecto com atributos A,B,C,XeY, <br>
	 * ignorar atributos X e Y passando como parametro.
	 */
	public static final int COPY_EXCEPT = 1;

	/**
	 * Copia os elementos apenas os elemento passado como parametros, <br>
	 * por exemplo objecto com atributos A,B,C,XeY, <br>
	 * copiar apenas atributos X e Y passando como parametro.
	 */
	public static final int COPY_ONLY = 2;

	/**
	 * Copia os elementos do objecto, todos os primitivos e os que so passados como parametros, <br>
	 * por exemplo objecto com atributos A,B e C como primitivos e X e Y como relacionamentos, <br>
	 * copiar os atributos primitivos A, B e C e mais o Y passando como parametro.
	 */
	public static final int COPY_SIMPLE_AND_CUSTOM = 3;

	/**
	 * Transfere o contedo da entidade origem para a entidade destino, mesmo que os objetos sejam de classes diferentes (atributos que tiverem o mesmo nome e mesmo tipo sero copiados). O modo pode
	 * ser COPY_ONLY para copiar apenas os atributos indicados ou COPY_EXCEPT para copiar todos exceto os indicados. <BR>
	 * Os atributos a serem fornecidos devem ser divididos pos vrgula e representar atributos que contenham metodos get e set na origem e no destino para que a cpia seja realizada(no modo COPY_ONLY)
	 * 
	 * @param mode
	 * @param attributes
	 * @param orign
	 * @param dest
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public static void copy(int mode, Object attributes, Object orign, Object dest) throws IllegalArgumentException,
			IllegalAccessException, InvocationTargetException {
		if (attributes instanceof String) {
			StringTokenizer st = new StringTokenizer((String) attributes, ",");
			Set<String> atts = new HashSet<String>();
			String att = null;
			while (st.hasMoreTokens()) {
				att = st.nextToken().trim();
				atts.add(att);
			}
			copy(mode, atts, orign, dest);
		} else if (attributes instanceof Object[]) {
			Object[] listAtt = (Object[]) attributes;
			for (int i = 0; i < listAtt.length; i++) {
				copy(mode, listAtt[i], orign, dest);
			}
		}
	}

	/**
	 * Transfere conteudo com recursividade //TODO document me!
	 * 
	 * @param mode
	 * @param attributes
	 * @param orign
	 * @param dest
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public static void copyRecursive(int mode, String attributes, Object orign, Object dest)
			throws IllegalArgumentException, IllegalAccessException, InvocationTargetException {
		StringTokenizer st = new StringTokenizer(attributes, ",");
		Set<String> atts = new HashSet<String>();
		while (st.hasMoreTokens()) {
			atts.add((String) st.nextElement());
		}
		copyRecursive(mode, atts, orign, dest);
	}

	/**
	 * Transfere o contedo da entidade origem para a entidade destino, mesmo que os objetos sejam de classes diferentes (atributos que tiverem o mesmo nome e mesmo tipo sero copiados). O modo pode
	 * ser COPY_ONLY para copiar apenas os atributos indicados ou COPY_EXCEPT para copiar todos exceto os indicados.
	 * 
	 * @param mode
	 * @param attributes
	 * @param orign
	 * @param dest
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public static void copy(int mode, Set<String> attributes, Object orign, Object dest)
			throws IllegalArgumentException, IllegalAccessException, InvocationTargetException {
		if (mode == COPY_ONLY && (attributes == null || (attributes != null && attributes.isEmpty()))) {
			System.out.println("Cpia no realizada no modo COPY_ONLY sem atributos definidos entre os objetos " + orign
					+ " e " + dest);
		}
		List<Accessor> orignAcList = new ArrayList<Accessor>(getAccessorsList(orign));
		Map<String, Accessor> destAcMap = new HashMap<String, Accessor>(getAccessorsMap(dest));
		for (Iterator<Accessor> i = orignAcList.iterator(); i.hasNext();) {
			Accessor acOrign = i.next();
			if (attributes == null || (attributes.contains(acOrign.getName()) && mode == COPY_ONLY)
					|| (!attributes.contains(acOrign.getName()) && mode == COPY_EXCEPT)) {
				Accessor acDest = destAcMap.get(acOrign.getName());
				if (acDest != null && acDest.isWriteable() && acOrign.isReadable()
						&& acDest.getType().equals(acOrign.getType())) {
					acDest.invokeSetter(dest, acOrign.invokeGetter(orign));
					// logger.debug("Atributo copiado - " + acOrign.getName() +
					// " - " + acOrign.invokeGetter(orign));
				}
			} else if ((acOrign.isJavaType() && mode == COPY_SIMPLE_AND_CUSTOM)
					|| (attributes.contains(acOrign.getName()) && mode == COPY_SIMPLE_AND_CUSTOM)) {
				Accessor acDest = destAcMap.get(acOrign.getName());
				if (acDest != null && acDest.isWriteable() && acOrign.isReadable()
						&& acDest.getType().equals(acOrign.getType())) {
					acDest.invokeSetter(dest, acOrign.invokeGetter(orign));
					// logger.debug("Atributo copiado - " + acOrign.getName() +
					// " - " + acOrign.invokeGetter(orign));
				}
			}

		}
	}

	/**
	 * Transfere o contedo da entidade origem para a entidade destino com recursividade, mesmo que os objetos sejam de classes diferentes (atributos que tiverem o mesmo nome e mesmo tipo sero
	 * copiados). O modo pode ser COPY_ONLY para copiar apenas os atributos indicados ou COPY_EXCEPT para copiar todos exceto os indicados.
	 * 
	 * @param mode
	 * @param attributes
	 * @param orign
	 * @param dest
	 * @throws IllegalArgumentException
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 */
	public static void copyRecursive(int mode, Set<String> attributes, Object orign, Object dest)
			throws IllegalArgumentException, IllegalAccessException, InvocationTargetException {
		if (mode == COPY_ONLY && (attributes == null || (attributes != null && attributes.isEmpty()))) {
			System.out.println("Cpia no realizada no modo COPY_ONLY sem atributos definidos entre os objetos " + orign
					+ " e " + dest);
		}
		List<Accessor> orignAcList = new ArrayList<Accessor>(getAccessorsList(orign));
		Map<String, Accessor> destAcMap = new HashMap<String, Accessor>(getAccessorsMap(dest));
		for (Iterator<Accessor> i = orignAcList.iterator(); i.hasNext();) {
			Accessor acOrign = i.next();
			if (attributes == null || (attributes.contains(acOrign.getName()) && mode == COPY_ONLY)
					|| (!attributes.contains(acOrign.getName()) && mode == COPY_EXCEPT)) {
				Accessor acDest = destAcMap.get(acOrign.getName());
				if (acDest != null && acDest.isWriteable() && acOrign.isReadable()
						&& acDest.getType().equals(acOrign.getType())) {
					acDest.invokeSetter(dest, acOrign.invokeGetter(orign));
					// Recursividade, copia o pai primeiro e depois os filhos.
					if (acDest.invokeGetter(orign) != null && acDest.isCollection()) {
						Object[] destinos = ((Collection) acDest.invokeGetter(dest)).toArray();
						Object[] origens = ((Collection) acOrign.invokeGetter(orign)).toArray();
						for (int j = 0; j < origens.length; j++) {
							copyRecursive(origens[j], destinos[j]);
						}
					}
					// logger.debug("Atributo copiado - " + acOrign.getName() +
					// " - " + acOrign.invokeGetter(orign));
				}
			} else if ((acOrign.isJavaType() && mode == COPY_SIMPLE_AND_CUSTOM)
					|| (attributes.contains(acOrign.getName()) && mode == COPY_SIMPLE_AND_CUSTOM)) {
				Accessor acDest = destAcMap.get(acOrign.getName());
				if (acDest != null && acDest.isWriteable() && acOrign.isReadable()
						&& acDest.getType().equals(acOrign.getType())) {
					acDest.invokeSetter(dest, acOrign.invokeGetter(orign));
					// logger.debug("Atributo copiado - " + acOrign.getName() +
					// " - " + acOrign.invokeGetter(orign));
				}
			}

		}
	}

	public static boolean isCompatible(Method getter, Method setter) {
		return getter == null
				|| setter == null
				|| (isGetter(getter) && isSetter(setter) && getAttributeName(getter).equals(getAttributeName(setter)) && getter
						.getReturnType().equals(setter.getParameterTypes()[0]));
	}

	public static Object invokeGetter(String attribute, Object obj) throws IllegalArgumentException,
			IllegalAccessException, InvocationTargetException {
		Accessor ac = getAccessor(attribute, obj);
		return ac.invokeGetter(obj);
	}

	public static Object invokeSetter(String attribute, Object obj, Object param) throws IllegalArgumentException,
			IllegalAccessException, InvocationTargetException {
		Accessor ac = getAccessor(attribute, obj);
		return ac.invokeSetter(obj, param);
	}

	public static boolean isConvertable(Class objectClass, Class clazz) {
		boolean convertable = ReflectionUtil.isCompatible(objectClass, clazz);
		if (!convertable) {
			if (clazz.equals(String.class)) {
				convertable = true;
			} else if (objectClass.equals(String.class)) {
				if (ReflectionUtil.isCompatible(clazz, Number.class)) {
					convertable = true;
				}
			}
		}
		return convertable;
	}

	public static boolean isConvertable(Object value, Class clazz) {
		return isConvertable(clazz, value.getClass());
	}

	public static Object convert(Object object, Class clazz) throws SecurityException, IllegalArgumentException {
		Class objectClass = object.getClass();
		if (isConvertable(object, clazz)) {
			Object converted = null;
			if (clazz.equals(String.class)) {
				converted = object.toString();
			} else if (objectClass.equals(String.class)) {
				if (ReflectionUtil.isCompatible(clazz, Number.class)) {
					try {
						converted = clazz.getConstructor(new Class[] { String.class }).newInstance(object);
					} catch (Exception e) {
						throw new RuntimeException();
					}
				}
			}
			return converted;
		}
		throw new IllegalArgumentException();
	}

}