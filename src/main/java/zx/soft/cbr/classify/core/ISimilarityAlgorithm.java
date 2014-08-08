package zx.soft.cbr.classify.core;

import java.util.Set;

/**
 * 
 * @author wanggang
 *
 */
public interface ISimilarityAlgorithm {

	Set<ICaseSimilarity> getSimilarity(ICase theCase, Set<ICase> similarCases, double threshold, Object... params);

}
