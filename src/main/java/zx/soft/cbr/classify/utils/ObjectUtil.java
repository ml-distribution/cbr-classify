package zx.soft.cbr.classify.utils;

import java.util.Calendar;

/**
 * 
 * @author wanggang
 *
 */
@SuppressWarnings({ "unchecked", "rawtypes" })
public class ObjectUtil {

	/**
	 * Chama o equals de a em b caso a e b nao sejam null, seno testa se a == b (true se os dois forem null)
	 * 
	 * @param a
	 * @param b
	 * @return true se o objeto a for igual ao b
	 */
	public static boolean equals(Object a, Object b) {
		boolean result;
		if (a != null && b != null) {
			result = a.equals(b);
		} else {
			result = a == b;
		}
		return result;
	}

	/**
	 * Chama o equals(pairs[i][0], pairs[i][1]) para cada i ou at que um false seja encontrado
	 * 
	 * @param pairs
	 * @return true se pairs[i][0] for igual a pairs[i][1] para todo i
	 */
	public static boolean equals(Object[][] pairs) {
		boolean result = true;
		int i = 0;
		while (result && i < pairs.length) {
			result &= equals(pairs[i][0], pairs[i][1]);
			i++;
		}
		return result;
	}

	/**
	 * Considera nulo menor que qualquer coisa <br>
	 * Se nenhum dos objetos for nulo, chama o compareTo do a em b, se o a for nulo, retorna -1 (nulo  menor que b), se o b for nulo, retorna 1 (a  maior que nulo) e se os dois forem nulos retorna 0
	 * (nulo  igual a nulo)
	 * 
	 * @param a
	 * @param b
	 * @return 0 se a for igual a b, negativo se a for menor que b e positivo se a for maior que b
	 */
	public static int compare(Comparable a, Comparable b) {
		int result;
		if (a != null && b != null) {
			result = a.compareTo(b);
		} else if (a == null && b != null) {
			result = -1;
		} else if (b == null && a != null) {
			result = 1;
		} else {
			result = 0;
		}
		return result;
	}

	/**
	 * Testa a em relao a b.
	 * 
	 * @param a
	 * @param b
	 * @return 0 se a for igual a b, negativo se a for menor que b e positivo se a for maior que b
	 */
	public static int compare(int a, int b) {
		return a - b;
	}

	public static int compare(Calendar a, Calendar b) {
		int result;
		if (a != null && b != null) {
			result = compare(a.getTime(), b.getTime());
		} else if (a == null && b != null) {
			result = -1;
		} else if (b == null && a != null) {
			result = 1;
		} else {
			result = 0;
		}
		return result;
	}

}
