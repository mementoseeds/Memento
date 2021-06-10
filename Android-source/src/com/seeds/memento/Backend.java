/*    This file is part of Memento.
 *
 *    Memento is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Memento is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Memento.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.seeds.memento;

import android.content.Context;
import android.app.Activity;
import android.content.Intent;

public class Backend
{
    public Backend() {}

    public static void androidOpenFileDialog(Activity activity)
    {
        Intent i = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        i.addCategory(Intent.CATEGORY_DEFAULT);
        activity.startActivityForResult(Intent.createChooser(i, "Choose directory"), 200);
    }
}