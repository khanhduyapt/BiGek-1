package codervi.bsc_scan.utils;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Tuple;
import javax.persistence.TupleElement;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

public class TupleUtils {

    @SuppressWarnings("rawtypes")
    public static List<ObjectNode> TupleToJson(List<Tuple> results) {

        List<ObjectNode> json = new ArrayList<>();

        ObjectMapper mapper = new ObjectMapper();

        for (Tuple tuple : results) {
            List<TupleElement<?>> cols = tuple.getElements();

            ObjectNode node = mapper.createObjectNode();

            for (TupleElement col : cols) {
                if (tuple.get(col.getAlias()) == null) {
                    node.put(col.getAlias(), (String) null);
                } else {
                    String typeName = col.getJavaType().getSimpleName();

                    switch (typeName) {
                    case "Short":
                        node.put(col.getAlias(), (Short) tuple.get(col.getAlias()));
                        break;
                    case "Long":
                        node.put(col.getAlias(), (Long) tuple.get(col.getAlias()));
                        break;
                    case "Float":
                        node.put(col.getAlias(), (Float) tuple.get(col.getAlias()));
                        break;
                    case "Double":
                        node.put(col.getAlias(), (Double) tuple.get(col.getAlias()));
                        break;
                    case "BigInteger":
                        node.put(col.getAlias(), (BigInteger) tuple.get(col.getAlias()));
                        break;
                    case "Integer":
                        node.put(col.getAlias(), (Integer) tuple.get(col.getAlias()));
                        break;
                    case "Boolean":
                        node.put(col.getAlias(), (Boolean) tuple.get(col.getAlias()));
                        break;
                    case "Date":
                        node.put(col.getAlias(), ((Date) tuple.get(col.getAlias())).getTime());
                        break;
                    case "BigDecimal":
                        node.put(col.getAlias(), (BigDecimal) tuple.get(col.getAlias()));
                        break;
                    case "Timestamp":
                        node.put(col.getAlias(), Timestamp.valueOf(tuple.get(col.getAlias()).toString()).getTime());
                        break;
                    default:
                        node.put(col.getAlias(), tuple.get(col.getAlias()).toString());
                        break;
                    }
                }
            }

            json.add(node);
        }
        return json;
    }
}
