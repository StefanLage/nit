/* This C header file is generated by NIT to compile modules and programs that requires ./metamodel/virtualtype. */
#ifndef metamodel___virtualtype_sep
#define metamodel___virtualtype_sep
#include "metamodel___type_formal._sep.h"
#include <nit_common.h>

extern const classtable_elt_t VFT_metamodel___virtualtype___MMTypeProperty[];

extern const classtable_elt_t VFT_metamodel___virtualtype___MMVirtualType[];
extern const char LOCATE_metamodel___virtualtype[];
extern const int SFT_metamodel___virtualtype[];
#define CALL_metamodel___virtualtype___MMGlobalProperty___is_virtual_type(recv) ((metamodel___virtualtype___MMGlobalProperty___is_virtual_type_t)CALL((recv), (SFT_metamodel___virtualtype[0] + 0)))
#define ID_metamodel___virtualtype___MMTypeProperty (SFT_metamodel___virtualtype[1])
#define COLOR_metamodel___virtualtype___MMTypeProperty (SFT_metamodel___virtualtype[2])
#define ATTR_metamodel___virtualtype___MMTypeProperty____stypes_cache(recv) ATTR(recv, (SFT_metamodel___virtualtype[3] + 0))
#define INIT_TABLE_POS_metamodel___virtualtype___MMTypeProperty (SFT_metamodel___virtualtype[4] + 0)
#define CALL_metamodel___virtualtype___MMTypeProperty___stype_for(recv) ((metamodel___virtualtype___MMTypeProperty___stype_for_t)CALL((recv), (SFT_metamodel___virtualtype[4] + 1)))
#define CALL_metamodel___virtualtype___MMTypeProperty___real_stype_for(recv) ((metamodel___virtualtype___MMTypeProperty___real_stype_for_t)CALL((recv), (SFT_metamodel___virtualtype[4] + 2)))
#define ID_metamodel___virtualtype___MMVirtualType (SFT_metamodel___virtualtype[5])
#define COLOR_metamodel___virtualtype___MMVirtualType (SFT_metamodel___virtualtype[6])
#define ATTR_metamodel___virtualtype___MMVirtualType____property(recv) ATTR(recv, (SFT_metamodel___virtualtype[7] + 0))
#define ATTR_metamodel___virtualtype___MMVirtualType____recv(recv) ATTR(recv, (SFT_metamodel___virtualtype[7] + 1))
#define INIT_TABLE_POS_metamodel___virtualtype___MMVirtualType (SFT_metamodel___virtualtype[8] + 0)
#define CALL_metamodel___virtualtype___MMVirtualType___property(recv) ((metamodel___virtualtype___MMVirtualType___property_t)CALL((recv), (SFT_metamodel___virtualtype[8] + 1)))
#define CALL_metamodel___virtualtype___MMVirtualType___recv(recv) ((metamodel___virtualtype___MMVirtualType___recv_t)CALL((recv), (SFT_metamodel___virtualtype[8] + 2)))
#define CALL_metamodel___virtualtype___MMVirtualType___init(recv) ((metamodel___virtualtype___MMVirtualType___init_t)CALL((recv), (SFT_metamodel___virtualtype[8] + 3)))
#define CALL_metamodel___virtualtype___MMLocalClass___virtual_type(recv) ((metamodel___virtualtype___MMLocalClass___virtual_type_t)CALL((recv), (SFT_metamodel___virtualtype[9] + 0)))
#define CALL_metamodel___virtualtype___MMLocalClass___select_virtual_type(recv) ((metamodel___virtualtype___MMLocalClass___select_virtual_type_t)CALL((recv), (SFT_metamodel___virtualtype[9] + 1)))
val_t metamodel___virtualtype___MMGlobalProperty___is_virtual_type(val_t p0);
typedef val_t (*metamodel___virtualtype___MMGlobalProperty___is_virtual_type_t)(val_t p0);
val_t NEW_MMGlobalProperty_metamodel___abstractmetamodel___MMGlobalProperty___init(val_t p0);
val_t metamodel___virtualtype___MMTypeProperty___stype_for(val_t p0, val_t p1);
typedef val_t (*metamodel___virtualtype___MMTypeProperty___stype_for_t)(val_t p0, val_t p1);
val_t metamodel___virtualtype___MMTypeProperty___real_stype_for(val_t p0, val_t p1);
typedef val_t (*metamodel___virtualtype___MMTypeProperty___real_stype_for_t)(val_t p0, val_t p1);
val_t NEW_MMTypeProperty_metamodel___abstractmetamodel___MMLocalProperty___init(val_t p0, val_t p1);
val_t metamodel___virtualtype___MMVirtualType___property(val_t p0);
typedef val_t (*metamodel___virtualtype___MMVirtualType___property_t)(val_t p0);
val_t metamodel___virtualtype___MMVirtualType___recv(val_t p0);
typedef val_t (*metamodel___virtualtype___MMVirtualType___recv_t)(val_t p0);
void metamodel___virtualtype___MMVirtualType___init(val_t p0, val_t p1, val_t p2, int* init_table);
typedef void (*metamodel___virtualtype___MMVirtualType___init_t)(val_t p0, val_t p1, val_t p2, int* init_table);
val_t NEW_MMVirtualType_metamodel___virtualtype___MMVirtualType___init(val_t p0, val_t p1);
val_t metamodel___virtualtype___MMVirtualType___mmmodule(val_t p0);
typedef val_t (*metamodel___virtualtype___MMVirtualType___mmmodule_t)(val_t p0);
val_t metamodel___virtualtype___MMVirtualType___for_module(val_t p0, val_t p1);
typedef val_t (*metamodel___virtualtype___MMVirtualType___for_module_t)(val_t p0, val_t p1);
val_t metamodel___virtualtype___MMVirtualType___not_for_self(val_t p0);
typedef val_t (*metamodel___virtualtype___MMVirtualType___not_for_self_t)(val_t p0);
val_t metamodel___virtualtype___MMVirtualType___adapt_to(val_t p0, val_t p1);
typedef val_t (*metamodel___virtualtype___MMVirtualType___adapt_to_t)(val_t p0, val_t p1);
val_t metamodel___virtualtype___MMLocalClass___virtual_type(val_t p0, val_t p1);
typedef val_t (*metamodel___virtualtype___MMLocalClass___virtual_type_t)(val_t p0, val_t p1);
val_t metamodel___virtualtype___MMLocalClass___select_virtual_type(val_t p0, val_t p1);
typedef val_t (*metamodel___virtualtype___MMLocalClass___select_virtual_type_t)(val_t p0, val_t p1);
val_t NEW_MMLocalClass_metamodel___abstractmetamodel___MMLocalClass___init(val_t p0, val_t p1, val_t p2);
#endif
